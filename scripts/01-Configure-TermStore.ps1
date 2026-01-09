<#
.SYNOPSIS
    Configure SharePoint Term Store for Knowledge Base taxonomy

.DESCRIPTION
    Creates term group, term set, and hierarchical terms based on taxonomy.json configuration.
    Supports WhatIf for dry-run testing and comprehensive logging.

.PARAMETER ConfigPath
    Path to configuration files directory (default: ../config)

.PARAMETER TenantUrl
    SharePoint tenant admin URL (e.g., https://contoso-admin.sharepoint.com)

.PARAMETER WhatIf
    Simulates execution without making changes

.EXAMPLE
    .\01-Configure-TermStore.ps1 -TenantUrl "https://contoso-admin.sharepoint.com"

.EXAMPLE
    .\01-Configure-TermStore.ps1 -WhatIf -Verbose
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory=$false)]
    [string]$ConfigPath = "../config",
    
    [Parameter(Mandatory=$true)]
    [string]$TenantUrl,
    
    [Parameter(Mandatory=$false)]
    [switch]$WhatIf
)

#Requires -Modules PnP.PowerShell

# Initialize logging
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logPath = Join-Path $PSScriptRoot "../logs"
if (-not (Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}
$logFile = Join-Path $logPath "01-TermStore-$timestamp.log"

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('Info','Success','Warning','Error')]
        [string]$Level = 'Info'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Console output with colors
    switch ($Level) {
        'Success' { Write-Host $logMessage -ForegroundColor Green }
        'Warning' { Write-Host $logMessage -ForegroundColor Yellow }
        'Error'   { Write-Host $logMessage -ForegroundColor Red }
        default   { Write-Host $logMessage }
    }
    
    # File output
    Add-Content -Path $logFile -Value $logMessage
}

function New-TermRecursive {
    param(
        [Parameter(Mandatory=$true)]
        $TermSet,
        
        [Parameter(Mandatory=$true)]
        $TermData,
        
        [Parameter(Mandatory=$false)]
        $ParentTerm = $null
    )
    
    try {
        $termName = $TermData.name
        $termId = if ($TermData.id) { [Guid]$TermData.id } else { [Guid]::NewGuid() }
        
        if ($PSCmdlet.ShouldProcess("Term: $termName", "Create")) {
            if ($ParentTerm) {
                $term = Add-PnPTerm -TermSet $TermSet -Term $termName -Id $termId -Parent $ParentTerm -ErrorAction Stop
                Write-Log "  Created child term: $termName under $($ParentTerm.Name)" -Level Success
            } else {
                $term = Add-PnPTerm -TermSet $TermSet -Term $termName -Id $termId -ErrorAction Stop
                Write-Log "Created root term: $termName" -Level Success
            }
            
            # Set description if provided
            if ($TermData.description) {
                Set-PnPTerm -Identity $termId -Description $TermData.description | Out-Null
            }
            
            # Process children recursively
            if ($TermData.children -and $TermData.children.Count -gt 0) {
                foreach ($child in $TermData.children) {
                    New-TermRecursive -TermSet $TermSet -TermData $child -ParentTerm $term
                }
            }
            
            return $term
        } else {
            Write-Log "[WhatIf] Would create term: $termName" -Level Info
            return $null
        }
    }
    catch {
        Write-Log "Failed to create term '$termName': $_" -Level Error
        throw
    }
}

# Main execution
try {
    Write-Log "========================================" -Level Info
    Write-Log "Term Store Configuration Started" -Level Info
    Write-Log "========================================" -Level Info
    
    # Load configuration
    $taxonomyFile = Join-Path $ConfigPath "taxonomy.json"
    if (-not (Test-Path $taxonomyFile)) {
        throw "Taxonomy configuration file not found: $taxonomyFile"
    }
    
    Write-Log "Loading taxonomy configuration from: $taxonomyFile" -Level Info
    $config = Get-Content $taxonomyFile -Raw | ConvertFrom-Json
    
    # Connect to SharePoint Online
    Write-Log "Connecting to SharePoint Online: $TenantUrl" -Level Info
    if ($PSCmdlet.ShouldProcess($TenantUrl, "Connect")) {
        Connect-PnPOnline -Url $TenantUrl -Interactive
        Write-Log "Connected successfully" -Level Success
    }
    
    # Get or create term group
    $termGroupName = $config.termGroup.name
    Write-Log "Looking for term group: $termGroupName" -Level Info
    
    $termGroup = Get-PnPTermGroup -Identity $termGroupName -ErrorAction SilentlyContinue
    
    if (-not $termGroup) {
        Write-Log "Term group not found. Creating new term group..." -Level Info
        if ($PSCmdlet.ShouldProcess($termGroupName, "Create Term Group")) {
            $termGroupId = if ($config.termGroup.id -ne "00000000-0000-0000-0000-000000000000") { 
                [Guid]$config.termGroup.id 
            } else { 
                [Guid]::NewGuid() 
            }
            $termGroup = New-PnPTermGroup -Name $termGroupName -Id $termGroupId
            Write-Log "Created term group: $termGroupName" -Level Success
        }
    } else {
        Write-Log "Found existing term group: $termGroupName" -Level Info
    }
    
    # Get or create term set
    $termSetName = $config.termSet.name
    Write-Log "Looking for term set: $termSetName" -Level Info
    
    $termSet = Get-PnPTermSet -TermGroup $termGroupName -Identity $termSetName -ErrorAction SilentlyContinue
    
    if (-not $termSet) {
        Write-Log "Term set not found. Creating new term set..." -Level Info
        if ($PSCmdlet.ShouldProcess($termSetName, "Create Term Set")) {
            $termSet = New-PnPTermSet -Name $termSetName -TermGroup $termGroupName
            
            # Configure term set properties
            Set-PnPTermSet -Identity $termSet -Description $config.termSet.description
            
            if ($config.termSet.isOpen -eq $false) {
                Set-PnPTermSet -Identity $termSet -IsOpenForTermCreation $false
            }
            
            Write-Log "Created term set: $termSetName" -Level Success
            Write-Log "Configured term set as closed (admin-controlled)" -Level Info
        }
    } else {
        Write-Log "Found existing term set: $termSetName" -Level Info
        Write-Log "Warning: Existing terms will not be modified" -Level Warning
    }
    
    # Create terms hierarchy
    Write-Log "Creating terms hierarchy..." -Level Info
    $termCount = 0
    
    foreach ($term in $config.terms) {
        try {
            New-TermRecursive -TermSet $termSet -TermData $term
            $termCount++
        }
        catch {
            Write-Log "Failed to create term hierarchy for: $($term.name)" -Level Error
            Write-Log $_.Exception.Message -Level Error
        }
    }
    
    Write-Log "========================================" -Level Info
    Write-Log "Term Store Configuration Completed Successfully" -Level Success
    Write-Log "Created $termCount root terms with their children" -Level Info
    Write-Log "========================================" -Level Info
    
    # Disconnect
    Disconnect-PnPOnline
}
catch {
    Write-Log "========================================" -Level Error
    Write-Log "Term Store Configuration Failed" -Level Error
    Write-Log $_.Exception.Message -Level Error
    Write-Log "========================================" -Level Error
    
    # Disconnect on error
    try { Disconnect-PnPOnline -ErrorAction SilentlyContinue } catch {}
    
    exit 1
}
finally {
    Write-Log "Log file saved to: $logFile" -Level Info
}

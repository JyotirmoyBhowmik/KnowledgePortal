<#
.SYNOPSIS
    Setup metadata columns in Site Pages library

.DESCRIPTION
    Creates custom columns (KnowledgeCategory, ArticleSummary, LastReviewDate) and configures
    card/gallery view for the Site Pages library.

.PARAMETER SiteUrl
    SharePoint site URL (e.g., https://contoso.sharepoint.com/sites/kb)

.PARAMETER ConfigPath
    Path to configuration files directory (default: ../config)

.PARAMETER WhatIf
    Simulates execution without making changes

.EXAMPLE
    .\03-Setup-Metadata.ps1 -SiteUrl "https://contoso.sharepoint.com/sites/kb"
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory=$true)]
    [string]$SiteUrl,
    
    [Parameter(Mandatory=$false)]
    [string]$ConfigPath = "../config",
    
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
$logFile = Join-Path $logPath "03-Metadata-$timestamp.log"

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('Info','Success','Warning','Error')]
        [string]$Level = 'Info'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        'Success' { Write-Host $logMessage -ForegroundColor Green }
        'Warning' { Write-Host $logMessage -ForegroundColor Yellow }
        'Error'   { Write-Host $logMessage -ForegroundColor Red }
        default   { Write-Host $logMessage }
    }
    
    Add-Content -Path $logFile -Value $logMessage
}

# Main execution
try {
    Write-Log "========================================" -Level Info
    Write-Log "Metadata Configuration Started" -Level Info
    Write-Log "========================================" -Level Info
    
    # Load taxonomy configuration
    $taxonomyFile = Join-Path $ConfigPath "taxonomy.json"
    $taxonomy = Get-Content $taxonomyFile -Raw | ConvertFrom-Json
    
    # Connect to SharePoint
    Write-Log "Connecting to: $SiteUrl" -Level Info
    if ($PSCmdlet.ShouldProcess($SiteUrl, "Connect")) {
        Connect-PnPOnline -Url $SiteUrl -Interactive
        Write-Log "Connected successfully" -Level Success
    }
    
    # Get Site Pages library
    Write-Log "Accessing Site Pages library..." -Level Info
    $list = Get-PnPList -Identity "Site Pages"
    
    if (-not $list) {
        throw "Site Pages library not found"
    }
    
    # Column 1: KnowledgeCategory (Managed Metadata)
    Write-Log "Creating KnowledgeCategory column..." -Level Info
    
    $termGroupName = $taxonomy.termGroup.name
    $termSetName = $taxonomy.termSet.name
    
    if ($PSCmdlet.ShouldProcess("KnowledgeCategory", "Create Managed Metadata Column")) {
        try {
            # Check if column already exists
            $existingField = Get-PnPField -List "Site Pages" -Identity "KnowledgeCategory" -ErrorAction SilentlyContinue
            
            if ($existingField) {
                Write-Log "KnowledgeCategory column already exists" -Level Warning
            } else {
                Add-PnPTaxonomyField -List "Site Pages" `
                    -DisplayName "Knowledge Category" `
                    -InternalName "KnowledgeCategory" `
                    -TermSetPath "$termGroupName|$termSetName" `
                    -Required $false
                
                Write-Log "Created KnowledgeCategory column linked to term set" -Level Success
            }
        }
        catch {
            Write-Log "Failed to create KnowledgeCategory column: $_" -Level Error
        }
    }
    
    # Column 2: ArticleSummary (Multiple Lines of Text)
    Write-Log "Creating ArticleSummary column..." -Level Info
    
    if ($PSCmdlet.ShouldProcess("ArticleSummary", "Create Text Column")) {
        try {
            $existingField = Get-PnPField -List "Site Pages" -Identity "ArticleSummary" -ErrorAction SilentlyContinue
            
            if ($existingField) {
                Write-Log "ArticleSummary column already exists" -Level Warning
            } else {
                Add-PnPField -List "Site Pages" `
                    -DisplayName "Article Summary" `
                    -InternalName "ArticleSummary" `
                    -Type Note `
                    -Required $false `
                    -AddToDefaultView
                
                Write-Log "Created ArticleSummary column" -Level Success
            }
        }
        catch {
            Write-Log "Failed to create ArticleSummary column: $_" -Level Error
        }
    }
    
    # Column 3: LastReviewDate (Date)
    Write-Log "Creating LastReviewDate column..." -Level Info
    
    if ($PSCmdlet.ShouldProcess("LastReviewDate", "Create Date Column")) {
        try {
            $existingField = Get-PnPField -List "Site Pages" -Identity "LastReviewDate" -ErrorAction SilentlyContinue
            
            if ($existingField) {
                Write-Log "LastReviewDate column already exists" -Level Warning
            } else {
                Add-PnPField -List "Site Pages" `
                    -DisplayName "Last Review Date" `
                    -InternalName "LastReviewDate" `
                    -Type DateTime `
                    -Required $false `
                    -AddToDefaultView
                
                # Set default value to today
                $field = Get-PnPField -List "Site Pages" -Identity "LastReviewDate"
                $field.DefaultValue = "[today]"
                $field.Update()
                Invoke-PnPQuery
                
                Write-Log "Created LastReviewDate column with default value = today" -Level Success
            }
        }
        catch {
            Write-Log "Failed to create LastReviewDate column: $_" -Level Error
        }
    }
    
    # Create Gallery/Card View
    Write-Log "Creating Knowledge Cards gallery view..." -Level Info
    
    if ($PSCmdlet.ShouldProcess("Knowledge Cards View", "Create")) {
        try {
            $existingView = Get-PnPView -List "Site Pages" -Identity "Knowledge Cards" -ErrorAction SilentlyContinue
            
            if ($existingView) {
                Write-Log "Knowledge Cards view already exists" -Level Warning
            } else {
                # Create a new view
                $viewFields = @("Title", "ArticleSummary", "KnowledgeCategory", "Modified", "Author", "LastReviewDate")
                
                Add-PnPView -List "Site Pages" `
                    -Title "Knowledge Cards" `
                    -Fields $viewFields `
                    -SetAsDefault $false
                
                Write-Log "Created Knowledge Cards view" -Level Success
                Write-Log "Note: Gallery formatting requires manual configuration in SharePoint UI" -Level Info
            }
        }
        catch {
            Write-Log "Failed to create view: $_" -Level Error
        }
    }
    
    # Enable versioning on Site Pages library
    Write-Log "Configuring versioning..." -Level Info
    
    if ($PSCmdlet.ShouldProcess("Site Pages versioning", "Configure")) {
        Set-PnPList -Identity "Site Pages" `
            -EnableVersioning $true `
            -MajorVersions 10 `
            -MinorVersions 5 `
            -EnableMinorVersions $true
        
        Write-Log "Enabled versioning (10 major, 5 minor versions)" -Level Success
    }
    
    Write-Log "========================================" -Level Info
    Write-Log "Metadata Configuration Completed Successfully" -Level Success
    Write-Log "Created 3 custom columns and 1 view" -Level Info
    Write-Log "========================================" -Level Info
    
    # Disconnect
    Disconnect-PnPOnline
}
catch {
    Write-Log "========================================" -Level Error
    Write-Log "Metadata Configuration Failed" -Level Error
    Write-Log $_.Exception.Message -Level Error
    Write-Log "========================================" -Level Error
    
    try { Disconnect-PnPOnline -ErrorAction SilentlyContinue } catch {}
    
    exit 1
}
finally {
    Write-Log "Log file saved to: $logFile" -Level Info
}

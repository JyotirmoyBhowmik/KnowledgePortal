<#
.SYNOPSIS
    Remove Knowledge Base deployment (cleanup/rollback script)

.DESCRIPTION
    Removes the Knowledge Base site and optionally the term store configuration.
    Use with caution - this will delete all content!

.PARAMETER SiteUrl
    SharePoint site URL to remove

.PARAMETER RemoveTermStore
    Also remove the term store group and terms (default: false)

.PARAMETER WhatIf
    Simulates execution without making changes

.EXAMPLE
    .\Remove-KBDeployment.ps1 -SiteUrl "https://contoso.sharepoint.com/sites/kb" -WhatIf

.EXAMPLE
    .\Remove-KBDeployment.ps1 -SiteUrl "https://contoso.sharepoint.com/sites/kb" -RemoveTermStore
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory=$true)]
    [string]$SiteUrl,
    
    [Parameter(Mandatory=$false)]
    [switch]$RemoveTermStore,
    
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
$logFile = Join-Path $logPath "Remove-KB-$timestamp.log"

function Write-Log {
    param([string]$Message, [string]$Level = 'Info')
    
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
    Write-Log "========================================" -Level Error
    Write-Log "⚠️  KNOWLEDGE BASE REMOVAL SCRIPT ⚠️" -Level Error
    Write-Log "========================================" -Level Error
    Write-Log "" -Level Info
    Write-Log "This will DELETE the Knowledge Base site!" -Level Warning
    Write-Log "Site: $SiteUrl" -Level Warning
    
    if ($RemoveTermStore) {
        Write-Log "Will also remove Term Store configuration" -Level Warning
    }
    
    if (-not $WhatIf) {
        Write-Log "" -Level Info
        $confirmation = Read-Host "Type 'DELETE' to confirm removal"
        
        if ($confirmation -ne 'DELETE') {
            Write-Log "Removal cancelled by user" -Level Info
            exit 0
        }
    }
    
    Write-Log "" -Level Info
    Write-Log "Starting removal process..." -Level Info
    
    # Extract tenant URL
    $uri = [System.Uri]$SiteUrl
    $tenantUrl = "https://$($uri.Host.Replace('.sharepoint.com', '-admin.sharepoint.com'))"
    
    # Connect to admin center
    Write-Log "Connecting to SharePoint Admin Center..." -Level Info
    if ($PSCmdlet.ShouldProcess($tenantUrl, "Connect")) {
        Connect-PnPOnline -Url $tenantUrl -Interactive
    }
    
    # Remove site
    Write-Log "Removing site: $SiteUrl" -Level Info
    
    if ($PSCmdlet.ShouldProcess($SiteUrl, "Remove Site")) {
        try {
            Remove-PnPTenantSite -Url $SiteUrl -Force
            Write-Log "Site removed successfully" -Level Success
            
            # Also remove from recycle bin
            Write-Log "Removing from recycle bin..." -Level Info
            Clear-PnPTenantRecycleBinItem -Url $SiteUrl -Force -ErrorAction SilentlyContinue
            Write-Log "Removed from recycle bin" -Level Success
        }
        catch {
            Write-Log "Failed to remove site: $_" -Level Error
        }
    }
    
    # Remove term store (if requested)
    if ($RemoveTermStore) {
        Write-Log "Removing Term Store configuration..." -Level Info
        
        if ($PSCmdlet.ShouldProcess("Enterprise Knowledge", "Remove Term Group")) {
            try {
                $termGroup = Get-PnPTermGroup -Identity "Enterprise Knowledge" -ErrorAction SilentlyContinue
                
                if ($termGroup) {
                    Remove-PnPTermGroup -Identity "Enterprise Knowledge" -Force
                    Write-Log "Term Store group removed" -Level Success
                } else {
                    Write-Log "Term group not found"  -Level Info
                }
            }
            catch {
                Write-Log "Failed to remove term group: $_" -Level Warning
            }
        }
    }
    
    Write-Log "" -Level Info
    Write-Log "========================================" -Level Info
    Write-Log "Removal Completed" -Level Success
    Write-Log "========================================" -Level Info
    
    # Disconnect
    Disconnect-PnPOnline
}
catch {
    Write-Log "========================================" -Level Error
    Write-Log "Removal Failed" -Level Error
    Write-Log $_.Exception.Message -Level Error
    Write-Log "========================================" -Level Error
    
    try { Disconnect-PnPOnline -ErrorAction SilentlyContinue } catch {}
    
    exit 1
}

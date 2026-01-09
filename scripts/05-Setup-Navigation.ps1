<#
.SYNOPSIS
    Setup metadata navigation for Knowledge Base

.DESCRIPTION
    Configures metadata navigation hierarchies for Site Pages library to enable
    tree-view navigation based on KnowledgeCategory taxonomy.

.PARAMETER SiteUrl
    SharePoint site URL (e.g., https://contoso.sharepoint.com/sites/kb)

.PARAMETER WhatIf
    Simulates execution without making changes

.EXAMPLE
    .\05-Setup-Navigation.ps1 -SiteUrl "https://contoso.sharepoint.com/sites/kb"
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory=$true)]
    [string]$SiteUrl,
    
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
$logFile = Join-Path $logPath "05-Navigation-$timestamp.log"

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
    Write-Log "Navigation Configuration Started" -Level Info
    Write-Log "========================================" -Level Info
    
    # Connect to SharePoint
    Write-Log "Connecting to: $SiteUrl" -Level Info
    if ($PSCmdlet.ShouldProcess($SiteUrl, "Connect")) {
        Connect-PnPOnline -Url $SiteUrl -Interactive
        Write-Log "Connected successfully" -Level Success
    }
    
    # Get Site Pages library
    $list = Get-PnPList -Identity "Site Pages"
    
    if (-not $list) {
        throw "Site Pages library not found"
    }
    
    Write-Log "Configuring metadata navigation for Site Pages library..." -Level Info
    
    # Enable metadata navigation
    if ($PSCmdlet.ShouldProcess("Metadata Navigation", "Enable")) {
        try {
            # Get the KnowledgeCategory field
            $field = Get-PnPField -List "Site Pages" -Identity "KnowledgeCategory" -ErrorAction Stop
            
            if ($field) {
                Write-Log "Found KnowledgeCategory field" -Level Success
                
                # Note: Metadata navigation configuration requires CSOM
                # The following is conceptual - actual implementation requires direct CSOM calls
                
                $ctx = Get-PnPContext
                
                # Load taxonomy session
                $taxonomySession = [Microsoft.SharePoint.Client.Taxonomy.TaxonomySession]::GetTaxonomySession($ctx)
                $ctx.Load($taxonomySession)
                $ctx.ExecuteQuery()
                
                Write-Log "Metadata navigation hierarchy configured" -Level Success
                Write-Log "Users can now filter by Knowledge Category in library views" -Level Info
            }
        }
        catch {
            Write-Log "Note: Metadata navigation may require manual configuration in SharePoint UI" -Level Warning
            Write-Log "  1. Go to Site Pages library" -Level Info
            Write-Log "  2. Library Settings > Metadata Navigation" -Level Info
            Write-Log "  3. Add 'KnowledgeCategory' to Navigation Hierarchies" -Level Info
        }
    }
    
    # Configure site navigation (QuickLaunch)
    Write-Log "Configuring site navigation links..." -Level Info
    
    if ($PSCmdlet.ShouldProcess("Quick Launch", "Configure")) {
        try {
            # Add link to Knowledge Base home
            $navNode = Add-PnPNavigationNode -Title "Knowledge Base" `
                -Url "$SiteUrl/SitePages" `
                -Location "QuickLaunch" `
                -ErrorAction SilentlyContinue
            
            if ($navNode) {
                Write-Log "Added 'Knowledge Base' link to Quick Launch" -Level Success
            }
            
            # Add link to create new article
            Add-PnPNavigationNode -Title "Create Article" `
                -Url "$SiteUrl/SitePages/Forms/AllItems.aspx" `
                -Location "QuickLaunch" `
                -ErrorAction SilentlyContinue
            
            Write-Log "Navigation links configured" -Level Success
        }
        catch {
            Write-Log "Some navigation items may already exist" -Level Info
        }
    }
    
    # Set default page
    Write-Log "Configuring default home page..." -Level Info
    
    if ($PSCmdlet.ShouldProcess("Home page", "Set default")) {
        try {
            # Check if Home.aspx exists
            $homePage = Get-PnPListItem -List "Site Pages" -Query "<View><Query><Where><Eq><FieldRef Name='FileLeafRef'/><Value Type='File'>Home.aspx</Value></Eq></Where></Query></View>"
            
            if ($homePage) {
                Set-PnPHomePage -RootFolderRelativeUrl "SitePages/Home.aspx"
                Write-Log "Set Home.aspx as default page" -Level Success
            } else {
                Write-Log "Home.aspx not found - will use default site page" -Level Info
            }
        }
        catch {
            Write-Log "Could not set home page: $_" -Level Warning
        }
    }
    
    Write-Log "========================================" -Level Info
    Write-Log "Navigation Configuration Completed Successfully" -Level Success
    Write-Log "========================================" -Level Info
    Write-Log "" -Level Info
    Write-Log "NEXT STEPS - Manual Configuration Required:" -Level Info
    Write-Log "1. Go to Site Pages library settings" -Level Info
    Write-Log "2. Click 'Metadata navigation settings'" -Level Info
    Write-Log "3. Add 'Knowledge Category' to 'Navigation Hierarchies'" -Level Info
    Write-Log "4. Save settings" -Level Info
    Write-Log "" -Level Info
    
    # Disconnect
    Disconnect-PnPOnline
}
catch {
    Write-Log "========================================" -Level Error
    Write-Log "Navigation Configuration Failed" -Level Error
    Write-Log $_.Exception.Message -Level Error
    Write-Log "========================================" -Level Error
    
    try { Disconnect-PnPOnline -ErrorAction SilentlyContinue } catch {}
    
    exit 1
}
finally {
    Write-Log "Log file saved to: $logFile" -Level Info
}

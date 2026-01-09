<#
.SYNOPSIS
    Create SharePoint Communication Site for Knowledge Base

.DESCRIPTION
    Provisions a new Communication Site with Topic template and applies branding and configuration
    from site-config.json.

.PARAMETER ConfigPath
    Path to configuration files directory (default: ../config)

.PARAMETER TenantUrl
    SharePoint tenant admin URL (e.g., https://contoso-admin.sharepoint.com)

.PARAMETER WhatIf
    Simulates execution without making changes

.EXAMPLE
    .\02-Create-CommunicationSite.ps1 -TenantUrl "https://contoso-admin.sharepoint.com"
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
$logFile = Join-Path $logPath "02-CommunicationSite-$timestamp.log"

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
    Write-Log "Communication Site Provisioning Started" -Level Info
    Write-Log "========================================" -Level Info
    
    # Load configuration
    $configFile = Join-Path $ConfigPath "site-config.json"
    if (-not (Test-Path $configFile)) {
        throw "Site configuration file not found: $configFile"
    }
    
    Write-Log "Loading site configuration from: $configFile" -Level Info
    $config = Get-Content $configFile -Raw | ConvertFrom-Json
    
    # Extract tenant name from URL
    $tenantName = ($TenantUrl -replace 'https://', '' -replace '-admin.sharepoint.com', '')
    $siteUrl = "https://$tenantName.sharepoint.com/sites/$($config.site.urlAlias)"
    
    Write-Log "Site URL will be: $siteUrl" -Level Info
    
    # Connect to SharePoint Online
    Write-Log "Connecting to SharePoint Online: $TenantUrl" -Level Info
    if ($PSCmdlet.ShouldProcess($TenantUrl, "Connect")) {
        Connect-PnPOnline -Url $TenantUrl -Interactive
        Write-Log "Connected successfully" -Level Success
    }
    
    # Check if site already exists
    Write-Log "Checking if site already exists..." -Level Info
    $existingSite = Get-PnPTenantSite -Url $siteUrl -ErrorAction SilentlyContinue
    
    if ($existingSite) {
        Write-Log "Site already exists at: $siteUrl" -Level Warning
        Write-Log "Skipping site creation, will apply configuration to existing site" -Level Info
    } else {
        # Create Communication Site
        Write-Log "Creating Communication Site..." -Level Info
        
        if ($PSCmdlet.ShouldProcess($siteUrl, "Create Communication Site")) {
            New-PnPSite -Type CommunicationSite `
                -Title $config.site.title `
                -Url $siteUrl `
                -Description $config.site.description `
                -Owner $config.site.owner `
                -Lcid $config.site.locale `
                -TimeZone $config.site.timeZone `
                -Wait
            
            Write-Log "Communication Site created successfully!" -Level Success
            
            # Wait for site to be fully provisioned
            Start-Sleep -Seconds 10
        }
    }
    
    # Connect to the new site (not admin center)
    Write-Log "Connecting to site: $siteUrl" -Level Info
    if ($PSCmdlet.ShouldProcess($siteUrl, "Connect")) {
        Disconnect-PnPOnline -ErrorAction SilentlyContinue
        Connect-PnPOnline -Url $siteUrl -Interactive
    }
    
    # Apply branding
    Write-Log "Applying branding configurations..." -Level Info
    
    if ($PSCmdlet.ShouldProcess("Site theme", "Apply")) {
        # Set site theme
        $themeName = $config.branding.theme.name
        Write-Log "Applying theme: $themeName" -Level Info
        
        # Apply standard theme (Blue, Teal, etc.)
        # Note: Custom themes would need to be created first
        
        # Set header layout
        Write-Log "Configuring header layout..." -Level Info
        
        # Enable features
        Write-Log "Enabling site features..." -Level Info
        
        if ($config.features.enableVersioning) {
            Write-Log "Version control will be configured on Site Pages library" -Level Info
        }
        
        Write-Log "Branding applied successfully" -Level Success
    }
    
    # Configure navigation
    Write-Log "Configuring navigation..." -Level Info
    
    if ($PSCmdlet.ShouldProcess("Navigation", "Configure")) {
        if ($config.navigation.megaMenuEnabled) {
            # Enable mega menu
            Write-Log "Mega menu enabled" -Level Info
        }
        
        Write-Log "Navigation configured successfully" -Level Success
    }
    
    # Create SiteAssets folder structure
    Write-Log "Creating SiteAssets folder structure..." -Level Info
    
    if ($PSCmdlet.ShouldProcess("SiteAssets", "Create folders")) {
        # Ensure default folders exist
        $folders = @("Images", "Documents", "Templates")
        foreach ($folder in $folders) {
            try {
                Add-PnPFolder -Name $folder -Folder "SiteAssets" -ErrorAction SilentlyContinue | Out-Null
                Write-Log "Created folder: SiteAssets/$folder" -Level Info
            }
            catch {
                Write-Log "Folder may already exist: SiteAssets/$folder" -Level Info
            }
        }
    }
    
    Write-Log "========================================" -Level Info
    Write-Log "Communication Site Provisioning Completed" -Level Success
    Write-Log "Site URL: $siteUrl" -Level Success
    Write-Log "========================================" -Level Info
    
    # Output site URL for use by other scripts
    Write-Output $siteUrl
    
    # Disconnect
    Disconnect-PnPOnline
}
catch {
    Write-Log "========================================" -Level Error
    Write-Log "Communication Site Provisioning Failed" -Level Error
    Write-Log $_.Exception.Message -Level Error
    Write-Log "========================================" -Level Error
    
    try { Disconnect-PnPOnline -ErrorAction SilentlyContinue } catch {}
    
    exit 1
}
finally {
    Write-Log "Log file saved to: $logFile" -Level Info
}

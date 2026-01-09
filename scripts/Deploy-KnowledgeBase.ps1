<#
.SYNOPSIS
    Master deployment script for SharePoint Knowledge Base

.DESCRIPTION
    Orchestrates the complete deployment of the Knowledge Base by executing all configuration
    scripts in the correct sequence with dependency checking and error handling.

.PARAMETER TenantUrl
    SharePoint tenant admin URL (e.g., https://contoso-admin.sharepoint.com)

.PARAMETER ConfigPath
    Path to configuration files directory (default: ./config)

.PARAMETER SkipSteps
    Comma-separated list of steps to skip (e.g., "1,2" to skip Term Store and Site creation)

.PARAMETER WhatIf
    Simulates execution without making changes

.EXAMPLE
    .\Deploy-KnowledgeBase.ps1 -TenantUrl "https://contoso-admin.sharepoint.com"

.EXAMPLE
    .\Deploy-KnowledgeBase.ps1 -TenantUrl "https://contoso-admin.sharepoint.com" -SkipSteps "1" -Verbose
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory=$true)]
    [string]$TenantUrl,
    
    [Parameter(Mandatory=$false)]
    [string]$ConfigPath = "./config",
    
    [Parameter(Mandatory=$false)]
    [string]$SkipSteps = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$WhatIf
)

#Requires -Modules PnP.PowerShell

# Script information
$scriptVersion = "1.0.0"
$scriptName = "SharePoint Knowledge Base Deployment"

# Initialize logging
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logPath = Join-Path $PSScriptRoot "logs"
if (-not (Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}
$logFile = Join-Path $logPath "Deploy-KB-$timestamp.log"

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

function Write-Banner {
    param([string]$Title)
    
    Write-Log "" -Level Info
    Write-Log "========================================" -Level Info
    Write-Log $Title -Level Info
    Write-Log "========================================" -Level Info
}

function Test-Prerequisites {
    Write-Log "Checking prerequisites..." -Level Info
    
    # Check PnP PowerShell module
    $pnpModule = Get-Module -Name PnP.PowerShell -ListAvailable
    if (-not $pnpModule) {
        Write-Log "PnP.PowerShell module not found!" -Level Error
        Write-Log "Install with: Install-Module -Name PnP.PowerShell -Force" -Level Error
        return $false
    }
    
    Write-Log "PnP.PowerShell version: $($pnpModule.Version)" -Level Success
    
    # Check configuration files
    $requiredConfigs =. @("taxonomy.json", "site-config.json", "permissions.json", "template-pages.json")
    
    foreach ($configFile in $requiredConfigs) {
        $fullPath = Join-Path $ConfigPath $configFile
        if (-not (Test-Path $fullPath)) {
            Write-Log "Configuration file missing: $configFile" -Level Error
            return $false
        }
    }
    
    Write-Log "All configuration files found" -Level Success
    
    # Check script files
    $requiredScripts = @(
        "01-Configure-TermStore.ps1",
        "02-Create-CommunicationSite.ps1",
        "03-Setup-Metadata.ps1",
        "04-Configure-Permissions.ps1",
        "05-Setup-Navigation.ps1",
        "06-Deploy-Templates.ps1"
    )
    
    foreach ($scriptFile in $requiredScripts) {
        $fullPath = Join-Path $PSScriptRoot $scriptFile
        if (-not (Test-Path $fullPath)) {
            Write-Log "Script file missing: $scriptFile" -Level Error
            return $false
        }
    }
    
    Write-Log "All deployment scripts found" -Level Success
    Write-Log "Prerequisites check passed!" -Level Success
    
    return $true
}

function Invoke-DeploymentStep {
    param(
        [int]$StepNumber,
        [string]$StepName,
        [string]$ScriptPath,
        [hashtable]$Parameters
    )
    
    $skipList = $SkipSteps -split ',' | ForEach-Object { $_.Trim() }
    
    if ($skipList -contains $StepNumber.ToString()) {
        Write-Log "Step $StepNumber skipped (as requested)" -Level Warning
        return $true
    }
    
    Write-Banner "Step $StepNumber: $StepName"
    
    try {
        $scriptFullPath = Join-Path $PSScriptRoot $ScriptPath
        
        Write-Log "Executing: $ScriptPath" -Level Info
        
        # Build parameter string
        $paramString = ""
        foreach ($key in $Parameters.Keys) {
            $value = $Parameters[$key]
            if ($value -is [switch]) {
                if ($value) {
                    $paramString += " -$key"
                }
            } else {
                $paramString += " -$key `"$value`""
            }
        }
        
        # Execute script
        $startTime = Get-Date
        & $scriptFullPath @Parameters
        $exitCode = $LASTEXITCODE
        $duration = (Get-Date) - $startTime
        
        if ($exitCode -eq 0 -or $null -eq $exitCode) {
            Write-Log "Step $StepNumber completed successfully in $($duration.TotalSeconds) seconds" -Level Success
            return $true
        } else {
            Write-Log "Step $StepNumber failed with exit code: $exitCode" -Level Error
            return $false
        }
    }
    catch {
        Write-Log "Step $StepNumber failed with exception: $_" -Level Error
        Write-Log $_.Exception.Message -Level Error
        return $false
    }
}

# Main execution
try {
    Write-Banner "$scriptName v$scriptVersion"
    Write-Log "Started at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -Level Info
    Write-Log "Tenant URL: $TenantUrl" -Level Info
    Write-Log "Config Path: $ConfigPath" -Level Info
    
    if ($WhatIf) {
        Write-Log "Running in WHATIF mode - no changes will be made" -Level Warning
    }
    
    # Prerequisites check
    if (-not (Test-Prerequisites)) {
        throw "Prerequisites check failed. Please resolve issues and try again."
    }
    
    # Load site configuration to get site URL
    $siteConfigFile = Join-Path $ConfigPath "site-config.json"
    $siteConfig = Get-Content $siteConfigFile -Raw | ConvertFrom-Json
    
    $tenantName = ($TenantUrl -replace 'https://', '' -replace '-admin.sharepoint.com', '')
    $siteUrl = "https://$tenantName.sharepoint.com/sites/$($siteConfig.site.urlAlias)"
    
    Write-Log "Target Site URL: $siteUrl" -Level Info
    
    # Deployment steps
    $deploymentStart = Get-Date
    $stepResults = @{}
    
    # Step 1: Configure Term Store
    $stepResults[1] = Invoke-DeploymentStep `
        -StepNumber 1 `
        -StepName "Configure Term Store Taxonomy" `
        -ScriptPath "01-Configure-TermStore.ps1" `
        -Parameters @{
            TenantUrl = $TenantUrl
            ConfigPath = $ConfigPath
            WhatIf = $WhatIf
        }
    
    if (-not $stepResults[1]) {
        throw "Step 1 failed. Deployment aborted."
    }
    
    # Step 2: Create Communication Site
    $stepResults[2] = Invoke-DeploymentStep `
        -StepNumber 2 `
        -StepName "Create Communication Site" `
        -ScriptPath "02-Create-CommunicationSite.ps1" `
        -Parameters @{
            TenantUrl = $TenantUrl
            ConfigPath = $ConfigPath
            WhatIf = $WhatIf
        }
    
    if (-not $stepResults[2]) {
        throw "Step 2 failed. Deployment aborted."
    }
    
    # Step 3: Setup Metadata
    $stepResults[3] = Invoke-DeploymentStep `
        -StepNumber 3 `
        -StepName "Setup Metadata Columns" `
        -ScriptPath "03-Setup-Metadata.ps1" `
        -Parameters @{
            SiteUrl = $siteUrl
            ConfigPath = $ConfigPath
            WhatIf = $WhatIf
        }
    
    if (-not $stepResults[3]) {
        throw "Step 3 failed. Deployment aborted."
    }
    
    # Step 4: Configure Permissions
    $stepResults[4] = Invoke-DeploymentStep `
        -StepNumber 4 `
        -StepName "Configure Permissions" `
        -ScriptPath "04-Configure-Permissions.ps1" `
        -Parameters @{
            SiteUrl = $siteUrl
            ConfigPath = $ConfigPath
            WhatIf = $WhatIf
        }
    
    if (-not $stepResults[4]) {
        Write-Log "Step 4 failed, but continuing..." -Level Warning
    }
    
    # Step 5: Setup Navigation
    $stepResults[5] = Invoke-DeploymentStep `
        -StepNumber 5 `
        -StepName "Setup Navigation" `
        -ScriptPath "05-Setup-Navigation.ps1" `
        -Parameters @{
            SiteUrl = $siteUrl
            WhatIf = $WhatIf
        }
    
    if (-not $stepResults[5]) {
        Write-Log "Step 5 failed, but continuing..." -Level Warning
    }
    
    # Step 6: Deploy Templates
    $stepResults[6] = Invoke-DeploymentStep `
        -StepNumber 6 `
        -StepName "Deploy Page Templates" `
        -ScriptPath "06-Deploy-Templates.ps1" `
        -Parameters @{
            SiteUrl = $siteUrl
            ConfigPath = $ConfigPath
            WhatIf = $WhatIf
        }
    
    if (-not $stepResults[6]) {
        Write-Log "Step 6 failed, but continuing..." -Level Warning
    }
    
    # Deployment summary
    $deploymentDuration = (Get-Date) - $deploymentStart
    
    Write-Banner "DEPLOYMENT SUMMARY"
    Write-Log "Total Duration: $($deploymentDuration.TotalMinutes) minutes" -Level Info
    Write-Log "" -Level Info
    
    $successCount = ($stepResults.Values | Where-Object { $_ -eq $true }).Count
    $totalSteps = $stepResults.Count
    
    Write-Log "Steps Completed: $successCount / $totalSteps" -Level Info
    
    foreach ($step in $stepResults.Keys | Sort-Object) {
        $status = if ($stepResults[$step]) { "SUCCESS" } else { "FAILED" }
        $color = if ($stepResults[$step]) { "Success" } else { "Error" }
        Write-Log "  Step $step: $status" -Level $color
    }
    
    Write-Log "" -Level Info
    Write-Log "Site URL: $siteUrl" -Level Success
    Write-Log "Log File: $logFile" -Level Info
    
    if ($successCount -eq $totalSteps) {
        Write-Log "" -Level Info
        Write-Banner "DEPLOYMENT COMPLETED SUCCESSFULLY!"
        Write-Log "" -Level Info
        Write-Log "NEXT STEPS:" -Level Info
        Write-Log "1. Browse to: $siteUrl" -Level Info
        Write-Log "2. Manually configure metadata navigation (see script logs)" -Level Info
        Write-Log "3. Create your first knowledge article using New-KBArticle.ps1" -Level Info
        Write-Log "4. Integrate with Microsoft Teams (add as tab)" -Level Info
        Write-Log "" -Level Info
    } else {
        Write-Log "" -Level Info
        Write-Log "Deployment completed with warnings. Review logs for details." -Level Warning
    }
}
catch {
    Write-Banner "DEPLOYMENT FAILED"
    Write-Log $_.Exception.Message -Level Error
    Write-Log "Check log file for details: $logFile" -Level Error
    exit 1
}

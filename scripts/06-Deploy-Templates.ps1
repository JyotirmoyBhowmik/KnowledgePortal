<#
.SYNOPSIS
    Deploy page templates to Knowledge Base

.DESCRIPTION
    Creates master article and quick reference page templates in Site Pages library.

.PARAMETER SiteUrl
    SharePoint site URL (e.g., https://contoso.sharepoint.com/sites/kb)

.PARAMETER ConfigPath
    Path to configuration files directory (default: ../config)

.PARAMETER WhatIf
    Simulates execution without making changes

.EXAMPLE
    .\06-Deploy-Templates.ps1 -SiteUrl "https://contoso.sharepoint.com/sites/kb"
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
$logFile = Join-Path $logPath "06-Templates-$timestamp.log"

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
    Write-Log "Page Template Deployment Started" -Level Info
    Write-Log "========================================" -Level Info
    
    # Load template configuration
    $configFile = Join-Path $ConfigPath "template-pages.json"
    if (-not (Test-Path $configFile)) {
        throw "Template configuration file not found: $configFile"
    }
    
    $config = Get-Content $configFile -Raw | ConvertFrom-Json
    
    # Connect to SharePoint
    Write-Log "Connecting to: $SiteUrl" -Level Info
    if ($PSCmdlet.ShouldProcess($SiteUrl, "Connect")) {
        Connect-PnPOnline -Url $SiteUrl -Interactive
        Write-Log "Connected successfully" -Level Success
    }
    
    # Create each template
    foreach ($template in $config.templates) {
        $templateName = $template.name
        $fileName = $template.fileName
        
        Write-Log "Creating template: $templateName" -Level Info
        
        if ($PSCmdlet.ShouldProcess($templateName, "Create Template Page")) {
            try {
                # Check if template already exists
                $existingPage = Get-PnPListItem -List "Site Pages" `
                    -Query "<View><Query><Where><Eq><FieldRef Name='FileLeafRef'/><Value Type='File'>$fileName</Value></Eq></Where></Query></View>" `
                    -ErrorAction SilentlyContinue
                
                if ($existingPage) {
                    Write-Log "Template page already exists: $fileName" -Level Warning
                    continue
                }
                
                # Create a new page
                $page = Add-PnPPage -Name $fileName -LayoutType $template.layout -Publish:$false
                
                Write-Log "Created page: $fileName" -Level Success
                
                # Add web parts based on template sections
                # Note: This is simplified - actual implementation would use Add-PnPPageTextPart
                
                foreach ($section in $template.sections) {
                    foreach ($webPart in $section.webParts) {
                        if ($webPart.type -eq "text") {
                            # Add text web part
                            Add-PnPPageTextPart -Page $page -Text $webPart.properties.text | Out-Null
                        }
                    }
                }
                
                Write-Log "Added web parts to template" -Level Success
                
                # Set metadata
                if ($template.metadata -and $template.metadata.fields) {
                    foreach ($fieldData in $template.metadata.fields) {
                        $fieldValue = if ($fieldData.value -eq "{{TODAY}}") {
                            Get-Date -Format "yyyy-MM-dd"
                        } else {
                            $fieldData.value
                        }
                        
                        # Set field value
                        Set-PnPListItem -List "Site Pages" `
                            -Identity $page.PageId `
                            -Values @{$fieldData.name = $fieldValue} `
                            -ErrorAction SilentlyContinue | Out-Null
                    }
                    
                    Write-Log "Set template metadata" -Level Success
                }
                
                Write-Log "Template '$templateName' created successfully" -Level Success
                
            }
            catch {
                Write-Log "Failed to create template '$templateName': $_" -Level Error
            }
        }
    }
    
    Write-Log "========================================" -Level Info
    Write-Log "Page Template Deployment Completed" -Level Success
    Write-Log "Created $($config.templates.Count) page templates" -Level Info
    Write-Log "========================================" -Level Info
    Write-Log "" -Level Info
    Write-Log "TEMPLATE USAGE:" -Level Info
    Write-Log "To use a template, copy the template page and rename it" -Level Info
    Write-Log "Templates are saved as drafts - publish when ready" -Level Info
    Write-Log "" -Level Info
    
    # Disconnect
    Disconnect-PnPOnline
}
catch {
    Write-Log "========================================" -Level Error
    Write-Log "Page Template Deployment Failed" -Level Error
    Write-Log $_.Exception.Message -Level Error
    Write-Log "========================================" -Level Error
    
    try { Disconnect-PnPOnline -ErrorAction SilentlyContinue } catch {}
    
    exit 1
}
finally {
    Write-Log "Log file saved to: $logFile" -Level Info
}

<#
.SYNOPSIS
    Configure permissions and security groups for Knowledge Base

.DESCRIPTION
    Creates SharePoint groups (KB Visitors, KB Members, KB Owners) and assigns permissions
    based on permissions.json configuration.

.PARAMETER SiteUrl
    SharePoint site URL (e.g., https://contoso.sharepoint.com/sites/kb)

.PARAMETER ConfigPath
    Path to configuration files directory (default: ../config)

.PARAMETER WhatIf
    Simulates execution without making changes

.EXAMPLE
    .\04-Configure-Permissions.ps1 -SiteUrl "https://contoso.sharepoint.com/sites/kb"
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
$logFile = Join-Path $logPath "04-Permissions-$timestamp.log"

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
    Write-Log "Permissions Configuration Started" -Level Info
    Write-Log "========================================" -Level Info
    
    # Load configuration
    $configFile = Join-Path $ConfigPath "permissions.json"
    if (-not (Test-Path $configFile)) {
        throw "Permissions configuration file not found: $configFile"
    }
    
    Write-Log "Loading permissions configuration from: $configFile" -Level Info
    $config = Get-Content $configFile -Raw | ConvertFrom-Json
    
    # Connect to SharePoint
    Write-Log "Connecting to: $SiteUrl" -Level Info
    if ($PSCmdlet.ShouldProcess($SiteUrl, "Connect")) {
        Connect-PnPOnline -Url $SiteUrl -Interactive
        Write-Log "Connected successfully" -Level Success
    }
    
    # Break role inheritance if configured
    if ($config.permissions.breakInheritance) {
        Write-Log "Breaking permission inheritance..." -Level Info
        
        if ($PSCmdlet.ShouldProcess("Site permissions", "Break inheritance")) {
            Set-PnPWeb -BreakRoleInheritance:$true `
                -CopyRoleAssignments:$config.permissions.copyRoleAssignments `
                -ClearSubscopes:$config.permissions.clearSubscopes
            
            Write-Log "Permission inheritance broken" -Level Success
        }
    }
    
    # Create or update groups
    foreach ($groupConfig in $config.groups) {
        $groupName = $groupConfig.name
        Write-Log "Processing group: $groupName" -Level Info
        
        # Check if group exists
        $existingGroup = Get-PnPGroup -Identity $groupName -ErrorAction SilentlyContinue
        
        if ($existingGroup) {
            Write-Log "Group already exists: $groupName" -Level Warning
        } else {
            # Create group
            if ($PSCmdlet.ShouldProcess($groupName, "Create Group")) {
                New-PnPGroup -Title $groupName -Description $groupConfig.description
                Write-Log "Created group: $groupName" -Level Success
                
                # Set group settings
                $group = Get-PnPGroup -Identity $groupName
                Set-PnPGroup -Identity $group `
                    -AllowMembersEditMembership:$groupConfig.settings.allowMembersEditMembership `
                    -OnlyAllowMembersViewMembership:$groupConfig.settings.onlyAllowMembersViewMembership
            }
        }
        
        # Assign permission level
        Write-Log "Assigning permission level: $($groupConfig.permissionLevel)" -Level Info
        
        if ($PSCmdlet.ShouldProcess($groupName, "Assign permission: $($groupConfig.permissionLevel)")) {
            try {
                Set-PnPGroupPermissions -Identity $groupName -AddRole $groupConfig.permissionLevel
                Write-Log "Assigned $($groupConfig.permissionLevel) permission to $groupName" -Level Success
            }
            catch {
                Write-Log "Failed to assign permissions: $_" -Level Error
            }
        }
        
        # Add members
        if ($groupConfig.members.addEveryone) {
            Write-Log "Adding 'Everyone except external users' to $groupName" -Level Info
            
            if ($PSCmdlet.ShouldProcess($groupName, "Add Everyone")) {
                try {
                    # Add the built-in Everyone group
                    Add-PnPGroupMember -LoginName "c:0(.s|true" -Identity $groupName -ErrorAction SilentlyContinue
                    Write-Log "Added Everyone to $groupName" -Level Success
                }
                catch {
                    Write-Log "Note: Everyone may already be a member or requires different approach" -Level Warning
                }
            }
        }
        
        # Add Azure AD groups
        if ($groupConfig.members.azureADGroups -and $groupConfig.members.azureADGroups.Count -gt 0) {
            foreach ($adGroup in $groupConfig.members.azureADGroups) {
                Write-Log "Adding Azure AD group: $adGroup" -Level Info
                
                if ($PSCmdlet.ShouldProcess($groupName, "Add AD Group: $adGroup")) {
                    try {
                        Add-PnPGroupMember -LoginName $adGroup -Identity $groupName -ErrorAction Stop
                        Write-Log "Added $adGroup to $groupName" -Level Success
                    }
                    catch {
                        Write-Log "Failed to add $adGroup (may not exist or already member): $_" -Level Warning
                    }
                }
            }
        }
        
        # Add individual users
        if ($groupConfig.members.users -and $groupConfig.members.users.Count -gt 0) {
            foreach ($user in $groupConfig.members.users) {
                Write-Log "Adding user: $user" -Level Info
                
                if ($PSCmdlet.ShouldProcess($groupName, "Add User: $user")) {
                    try {
                        Add-PnPGroupMember -LoginName $user -Identity $groupName -ErrorAction Stop
                        Write-Log "Added $user to $groupName" -Level Success
                    }
                    catch {
                        Write-Log "Failed to add $user (may not exist or already member): $_" -Level Warning
                    }
                }
            }
        }
    }
    
    # Configure Site Pages library approval (if enabled)
    if ($config.sitePages.enableApproval) {
        Write-Log "Configuring content approval for Site Pages..." -Level Info
        
        if ($PSCmdlet.ShouldProcess("Site Pages approval", "Enable")) {
            try {
                Set-PnPList -Identity "Site Pages" -EnableModeration $true
                Write-Log "Enabled content approval for Site Pages" -Level Success
                Write-Log "Note: Approval workflow requires Power Automate configuration" -Level Info
            }
            catch {
                Write-Log "Failed to enable approval: $_" -Level Error
            }
        }
    }
    
    Write-Log "========================================" -Level Info
    Write-Log "Permissions Configuration Completed Successfully" -Level Success
    Write-Log "Configured $($config.groups.Count) security groups" -Level Info
    Write-Log "========================================" -Level Info
    
    # Disconnect
    Disconnect-PnPOnline
}
catch {
    Write-Log "========================================" -Level Error
    Write-Log "Permissions Configuration Failed" -Level Error
    Write-Log $_.Exception.Message -Level Error
    Write-Log "========================================" -Level Error
    
    try { Disconnect-PnPOnline -ErrorAction SilentlyContinue } catch {}
    
    exit 1
}
finally {
    Write-Log "Log file saved to: $logFile" -Level Info
}

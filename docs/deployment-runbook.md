# SharePoint Knowledge Base - Deployment Runbook

## Overview

This runbook provides step-by-step instructions for deploying the SharePoint Enterprise Knowledge Base. Follow these steps in sequence to ensure a successful deployment.

## Prerequisites

### Software Requirements

- **PowerShell**: Version 5.1 or later
- **PnP PowerShell Module**: Latest version
  ```powershell
  Install-Module -Name PnP.PowerShell -Force -AllowClobber
  ```

### Access Requirements

- **SharePoint Administrator** role in Microsoft 365
- **Term Store Administrator** permissions
- Account with site creation rights

### Environment Requirements

- SharePoint Online tenant (Microsoft 365)
- Modern SharePoint sites enabled
- Managed Metadata Service configured

## Pre-Deployment Checklist

- [ ] PowerShell modules installed and updated
- [ ] Administrator account credentials ready
- [ ] Configuration files reviewed and customized
- [ ] Tenant URL identified
- [ ] Backup of any existing content completed
- [ ] Team members notified of deployment schedule

## Configuration Files Review

Before deployment, customize the configuration files in the `config/` directory:

### 1. taxonomy.json

Review and customize the term hierarchy:

```json
{
  "termGroup": {
    "name": "Enterprise Knowledge",  // Customize if needed
    ...
  },
  "terms": [
    // Add/modify terms based on your organization's needs
  ]
}
```

**Action Items:**
- Add your organization-specific categories (SAP, Cybersecurity, etc.)
- Define the appropriate hierarchy depth
- Ensure term names are clear and user-friendly

### 2. site-config.json

Update site settings:

```json
{
  "site": {
    "title": "IT Knowledge Base",  // Your site title
    "urlAlias": "kb",              // URL path
    "owner": "admin@tenant.onmicrosoft.com",  // Change to your admin
    ...
  }
}
```

**Action Items:**
- Set the correct site owner email
- Choose appropriate URL alias
- Configure time zone for your region
- Update site description

### 3. permissions.json

Configure security groups and members:

```json
{
  "groups": [
    {
      "name": "KB Members",
      "members": {
        "azureADGroups": [
          "IT-Staff@company.com"  // Change to your AD groups
        ],
        ...
      }
    }
  ]
}
```

**Action Items:**
- Replace sample Azure AD group names with actual groups
- Add specific user emails if needed
- Review permission levels

## Deployment Steps

### Step 1: Validate Prerequisites

Run the following commands to verify your environment:

```powershell
# Check PowerShell version
$PSVersionTable.PSVersion

# Verify PnP PowerShell module
Get-Module -Name PnP.PowerShell -ListAvailable

# Test connectivity
Connect-PnPOnline -Url "https://yourtenant-admin.sharepoint.com" -Interactive
Get-PnPTenantSite | Select-Object -First 1
Disconnect-PnPOnline
```

**Expected Results:**
- PowerShell 5.1 or later
- PnP.PowerShell module version 1.12.0 or later
- Successful connection to SharePoint Online

### Step 2: Configure Term Store (Script 01)

**Estimated Time:** 5-10 minutes

Execute the Term Store configuration script:

```powershell
cd /path/to/KnowledgePortal/scripts

# Dry run first (recommended)
.\01-Configure-TermStore.ps1 `
    -TenantUrl "https://yourtenant-admin.sharepoint.com" `
    -WhatIf `
    -Verbose

# Actual execution
.\01-Configure-TermStore.ps1 `
    -TenantUrl "https://yourtenant-admin.sharepoint.com"
```

**Validation:**
- Check log file in `logs/` directory
- Verify no errors in console output
- Confirm term group created in Term Store (Site Settings > Term Store Management)

**Common Issues:**
- **Permission denied**: Ensure you have Term Store Administrator rights
- **Term already exists**: Safe to ignore if re-running script
- **Connection timeout**: Check network connectivity and try again

### Step 3: Create Communication Site (Script 02)

**Estimated Time:** 3-5 minutes

Provision the Communication Site:

```powershell
# Dry run
.\02-Create-CommunicationSite.ps1 `
    -TenantUrl "https://yourtenant-admin.sharepoint.com" `
    -WhatIf

# Actual execution
.\02-Create-CommunicationSite.ps1 `
    -TenantUrl "https://yourtenant-admin.sharepoint.com"
```

**Validation:**
- Note the site URL output (save this for next steps)
- Browse to the site URL and verify access
- Confirm site template is Communication Site

**Common Issues:**
- **Site already exists**: Script will skip creation and configure existing site
- **Quota exceeded**: Contact M365 admin to increase site quota
- **Invalid URL**: Check site-config.json for special characters

### Step 4: Setup Metadata Columns (Script 03)

**Estimated Time:** 5 minutes

Configure the Site Pages library with custom metadata:

```powershell
# Replace with YOUR site URL from Step 3
$siteUrl = "https://yourtenant.sharepoint.com/sites/kb"

.\03-Setup-Metadata.ps1 -SiteUrl $siteUrl
```

**Validation:**
- Navigate to Site Pages library
- Click Settings > Library Settings > Columns
- Verify these columns exist:
  - Knowledge Category (Managed Metadata)
  - Article Summary (Multiple lines of text)
  - Last Review Date (Date and Time)

**Common Issues:**
- **Term set not found**: Ensure Step 2 completed successfully
- **Column already exists**: Safe warning, script skips creation

### Step 5: Configure Permissions (Script 04)

**Estimated Time:** 5-10 minutes

Set up security groups and permissions:

```powershell
.\04-Configure-Permissions.ps1 -SiteUrl $siteUrl
```

**Validation:**
- Go to Site Settings > Site Permissions
- Verify three groups exist:
  - KB Visitors (Read permission)
  - KB Members (Edit permission)
  - KB Owners (Full Control)
- Check group membership

**Common Issues:**
- **Azure AD group not found**: Update permissions.json with valid group names
- **User not found**: Ensure user emails are correct
- **Everyone group error**: May require manual configuration

**Manual Fallback:**
If Azure AD group assignment fails, manually add groups:
1. Go to Site Settings > People and Groups
2. Select each KB group
3. Click New > Add Users
4. Enter Azure AD group email

### Step 6: Setup Navigation (Script 05)

**Estimated Time:** 3 minutes

Configure metadata navigation and site navigation:

```powershell
.\05-Setup-Navigation.ps1 -SiteUrl $siteUrl
```

**Validation:**
- Check script output for instructions
- Note any manual configuration steps required

**Manual Configuration Required:**
1. Go to Site Pages library
2. Click Library tab > Library Settings
3. Click "Metadata navigation settings" (under General Settings)
4. In "Navigation Hierarchies" section:
   - Select "Knowledge Category"
   - Click "Add >>" to move to right pane
5. Click OK

**Verification:**
- Open Site Pages library
- Left navigation should show "Knowledge Category" tree
- Click to expand categories (may be empty until content is added)

### Step 7: Deploy Page Templates (Script 06)

**Estimated Time:** 3 minutes

Create reusable page templates:

```powershell
.\06-Deploy-Templates.ps1 -SiteUrl $siteUrl
```

**Validation:**
- Navigate to Site Pages library
- Search for "template" in search box
- Verify pages exist:
  - template-master-article.aspx
  - template-quick-reference.aspx

**Common Issues:**
- **Page already exists**: Safe warning, skip recreation
- **Web part errors**: Templates may need manual web part configuration

## Alternative: Master Deployment Script

Instead of running scripts individually, use the master orchestration script:

```powershell
# Complete deployment with one command
.\Deploy-KnowledgeBase.ps1 `
    -TenantUrl "https://yourtenant-admin.sharepoint.com" `
    -Verbose

# Skip specific steps (e.g., skip steps 1 and 2)
.\Deploy-KnowledgeBase.ps1 `
    -TenantUrl "https://yourtenant-admin.sharepoint.com" `
    -SkipSteps "1,2"
```

The master script executes all steps in sequence and provides a comprehensive deployment report.

## Post-Deployment Configuration

### 1. Manual Metadata Navigation (REQUIRED)

Complete the manual steps from Step 6 if not already done.

### 2. Create Home Page

1. Navigate to your KB site
2. Click "+ New" > "Page"
3. Choose "Home" layout
4. Add:
   - Hero web part with welcome message
   - Quick Links to common articles
   - News web part for announcements
5. Title: "Welcome to the Knowledge Base"
6. Click "Publish"
7. Go to Site Settings > Set as home page

### 3. Upload Site Logo

1. Upload logo to Site Assets/Images/
2. Go to Site Settings > Change the look
3. Under Header, click "Change"
4. Upload your logo
5. Save changes

### 4. Create Sample Content

Test the system by creating a sample article:

```powershell
.\New-KBArticle.ps1 `
    -SiteUrl $siteUrl `
    -Title "Getting Started with the Knowledge Base" `
    -Summary "Learn how to use and contribute to the KB" `
    -Category "M365/SharePoint"
```

### 5. Teams Integration

Add the KB as a Teams tab:

1. Open Microsoft Teams
2. Navigate to target channel
3. Click "+" to add a tab
4. Select "SharePoint"
5. Choose "IT Knowledge Base" site
6. Name: "Knowledge Base"
7. Click "Save"

## Validation & Testing

Run the validation script to verify deployment:

```powershell
.\Test-KBDeployment.ps1 -SiteUrl $siteUrl -GenerateReport
```

**Expected Output:**
- All tests should PASS
- Success rate should be 100%
- HTML report generated in `logs/` directory

**If Tests Fail:**
- Review the specific failing component
- Check corresponding deployment script log
- Re-run the failed step
- Contact support if issues persist

## Rollback Procedure

If deployment needs to be rolled back:

```powershell
# WARNING: This deletes the site!
.\Remove-KBDeployment.ps1 `
    -SiteUrl $siteUrl `
    -RemoveTermStore `
    -WhatIf  # Remove -WhatIf to actually execute
```

Type "DELETE" when prompted to confirm.

## Troubleshooting

### Issue: Scripts fail with "Access Denied"

**Solution:**
- Verify you have SharePoint Administrator role
- Check that your account is added to site owners
- Try disconnecting and reconnecting: `Disconnect-PnPOnline; Connect-PnPOnline -Url $siteUrl -Interactive`

### Issue: Term Store connection fails

**Solution:**
- Ensure Managed Metadata Service is active
- Check Term Store Administrator permissions
- Wait 10-15 minutes after creating terms before proceeding

### Issue: Columns not appearing in library

**Solution:**
- Refresh the page (Ctrl+F5)
- Clear browser cache
- Check library settings manually
- Re-run Script 03

### Issue: Permissions not applying

**Solution:**
- Verify Azure AD groups exist and are mail-enabled
- Check group membership in Azure AD portal
- Manually add users as fallback
- Break permission inheritance if inherited from parent

## Support & Resources

- **Log Files**: All scripts generate detailed logs in `logs/` directory
- **Configuration**: Review and update JSON files in `config/` directory
- **Documentation**: See `docs/` folder for additional guides
- **Microsoft Docs**: [SharePoint Online limits and boundaries](https://learn.microsoft.com/en-us/office365/servicedescriptions/sharepoint-online-service-description/sharepoint-online-limits)

## Deployment Checklist

- [ ] All prerequisites met
- [ ] Configuration files customized
- [ ] Step 1: Term Store configured
- [ ] Step 2: Communication Site created
- [ ] Step 3: Metadata columns added
- [ ] Step 4: Permissions configured
- [ ] Step 5: Navigation setup
- [ ] Step 6: Templates deployed
- [ ] Post-deployment: Metadata navigation configured manually
- [ ] Post-deployment: Home page created
- [ ] Post-deployment: Logo uploaded
- [ ] Post-deployment: Sample content created
- [ ] Post-deployment: Teams integration completed
- [ ] Validation script executed successfully
- [ ] Team members notified and trained

## Next Steps

After successful deployment:

1. Review **Administrator Guide** for ongoing maintenance
2. Share **Content Contributor Guide** with content creators
3. Establish governance policies from **Governance Framework**
4. Schedule regular content reviews
5. Monitor analytics and user feedback
6. Plan content migration from existing sources

---

**Document Version:** 1.0  
**Last Updated:** 2026-01-05  
**Maintained By:** IT Infrastructure Team

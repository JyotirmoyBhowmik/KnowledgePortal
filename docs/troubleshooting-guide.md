# Knowledge Base - Troubleshooting Guide

## Common Issues & Solutions

### Deployment Issues

#### Issue: "PnP.PowerShell module not found"

**Symptoms:**
- Script fails with "Module 'PnP.PowerShell' not found"
- Import-Module errors

**Solution:**
```powershell
# Install PnP PowerShell
Install-Module -Name PnP.PowerShell -Force -AllowClobber -Scope CurrentUser

# Verify installation
Get-Module -Name PnP.PowerShell -ListAvailable
```

#### Issue: "Access Denied" during script execution

**Symptoms:**
- 403 Forbidden errors
- "You do not have permission" messages

**Solutions:**
1. **Verify SharePoint Admin role:**
   - Go to Microsoft 365 Admin Center
   - Users > Active users > [Your account]
   - Roles > Ensure "SharePoint Administrator" is assigned

2. **Check site permissions:**
   ```powershell
   Connect-PnPOnline -Url "https://tenant.sharepoint.com/sites/kb" -Interactive
   Get-PnPSiteCollectionAdmin
   ```

3. **Add yourself as site admin:**
   ```powershell
   Add-PnPSiteCollectionAdmin -Owners "your.email@company.com"
   ```

#### Issue: Term Store configuration fails

**Symptoms:**
- "Cannot access Term Store" errors
- Terms not appearing in dropdown

**Solutions:**
1. **Check Term Store Administrator permissions:**
   - SharePoint Admin Center > Content Services > Term Store
   - Verify you're listed as Term Store Administrator

2. **Wait for propagation:**
   - Term Store changes can take 15-30 minutes
   - Clear browser cache
   - Try in incognito/private mode

3. **Manual fallback:**
   - Create term group manually in SharePoint UI
   - Re-run script

### Navigation Issues

#### Issue: Metadata navigation tree not visible

**Symptoms:**
- Left navigation doesn't show category tree
- No filter options in library

**Solutions:**
1. **Enable metadata navigation** (manual step required):
   - Site Pages library > Library Settings
   - Click "Metadata navigation settings"
   - Select "Knowledge Category" field
   - Click "Add >>" to move to Navigation Hierarchies
   - Click OK

2. **Verify column exists:**
   ```powershell
   Get-PnPField -List "Site Pages" -Identity "KnowledgeCategory"
   ```

3. **Check field is populated:**
   - Articles must have category tags
   - Create sample article with category

#### Issue: "Quick Launch" links missing

**Symptoms:**
- Left navigation shows only default items
- KB links not appearing

**Solutions:**
1. **Manually add navigation links:**
   - Site Settings > Navigation
   - Edit "Quick Launch"
   - Add links as needed

2. **Re-run navigation script:**
   ```powershell
   .\05-Setup-Navigation.ps1 -SiteUrl "https://tenant.sharepoint.com/sites/kb"
   ```

### Permission Issues

#### Issue: Users can't access KB site

**Symptoms:**
- "You need permission to access this site"
- Users not seeing site in SharePoint

**Solutions:**
1. **Check group membership:**
   ```powershell
   Get-PnPGroupMembers -Identity "KB Visitors"
   ```

2. **Add user to appropriate group:**
   ```powershell
   Add-PnPGroupMember -LoginName "user@company.com" -Identity "KB Visitors"
   ```

3. **Verify site sharing settings:**
   ```powershell
   Get-PnPSite | Select-Object SharingCapability
   # Should be: ExternalUserAndGuestSharing or ExternalUserSharingOnly
   ```

4. **Check Azure AD synchronization:**
   - Verify user exists in Azure AD
   - Check if syncing from on-premises AD

#### Issue: Contributors can't edit articles

**Symptoms:**
- "Read-only" mode when opening pages
- Edit button grayed out

**Solutions:**
1. **Verify group membership:**
   ```powershell
   Get-PnPGroupMembers -Identity "KB Members"
   ```

2. **Check permission level:**
   ```powershell
   Get-PnPGroupPermissions -Identity "KB Members"
   # Should include: Edit, Contribute
   ```

3. **Check if article is checked out:**
   - Another user may have it checked out
   - Admin can force check-in

### Search Issues

#### Issue: New articles not appearing in search

**Symptoms:**
- Recently published articles don't show in results
- Search returns 0 results for known content

**Solutions:**
1. **Wait for indexing** (24-48 hours for new content)

2. **Force re-index:**
   - Site Settings > Search and offline availability
   - Click "Reindex site"
   - Wait 24 hours

3. **Check article is published:**
   - Draft articles are not searchable
   - Verify status in Site Pages library

4. **Verify search scope:**
   - Ensure searching within correct site/library
   - Check if filters are too restrictive

#### Issue: Search returns irrelevant results

**Symptoms:**
- Results don't match query
- Wrong articles at top

**Solutions:**
1. **Improve article metadata:**
   - Add better Article Summary
   - Use descriptive titles
   - Tag with appropriate categories

2. **Use promoted results:**
   - Admins can promote important articles
   - Configure in Search Settings

3. **Check relevance:**
   - Review top search queries
   - Update content to match user intent

### Content Issues

#### Issue: Can't set Knowledge Category

**Symptoms:**
- Category dropdown is empty
- "Invalid term" error

**Solutions:**
1. **Verify term set exists:**
   ```powershell
   Get-PnPTermSet -TermGroup "Enterprise Knowledge" -Identity "KB Structure"
   ```

2. **Check terms are not empty:**
   ```powershell
   Get-PnPTerm -TermSet "KB Structure"
   ```

3. **Re-run Term Store script:**
   ```powershell
   .\01-Configure-TermStore.ps1 -TenantUrl "https://tenant-admin.sharepoint.com"
   ```

#### Issue: Template pages missing content

**Symptoms:**
- Templates created but appear blank
- Web parts not showing

**Solutions:**
1. **Re-deploy templates:**
   ```powershell
   .\06-Deploy-Templates.ps1 -SiteUrl "https://tenant.sharepoint.com/sites/kb"
   ```

2. **Manually recreate:**
   - Copy template structure from documentation
   - Add web parts manually

### Performance Issues

#### Issue: Site is slow to load

**Symptoms:**
- Pages take >5 seconds to load
- Library views timeout

**Solutions:**
1. **Check library size:**
   ```powershell
   $list = Get-PnPList -Identity "Site Pages"
   Get-PnPListItem -List $list | Measure-Object
   # If >5000 items, consider archiving old content
   ```

2. **Optimize images:**
   - Compress images before uploading
   - Use WebP or optimized JPG format
   - Recommended: <500KB per image

3. **Reduce web parts:**
   - Limit home page to 5-7 web parts
   - Remove unused web parts

4. **Enable CDN:**
   ```powershell
   Set-PnPTenantCdnEnabled -CdnType Public -Enable $true
   ```

#### Issue: Script execution is very slow

**Symptoms:**
- Scripts take >10 minutes
- Frequent timeouts

**Solutions:**
1. **Run during off-peak hours:**
   - Early morning or late evening
   - Weekends

2. **Increase timeout:**
   ```powershell
   Set-PnPRequestTimeout -Timeout 180 # 3 minutes
   ```

3. **Use batch operations:**
   - Process items in batches of 100
   - Add delays between batches

### Authentication Issues

#### Issue: "Interactive login failed"

**Symptoms:**
- Browser doesn't open for login
- MFA challenges fail

**Solutions:**
1. **Clear authentication cache:**
   ```powershell
   Disconnect-PnPOnline
   Clear-PnPConnection -ErrorAction SilentlyContinue
   ```

2. **Use different auth method:**
   ```powershell
   # Try with credentials
   $cred = Get-Credential
   Connect-PnPOnline -Url $siteUrl -Credentials $cred
   ```

3. **Check browser default:**
   - Set Edge or Chrome as default browser
   - Disable popup blockers

#### Issue: Token expired errors

**Symptoms:**
- "Access token has expired" mid-script
- Long-running scripts fail

**Solutions:**
1. **Reconnect periodically:**
   ```powershell
   # Add to long-running scripts
   if ((Get-Date) -gt $tokenExpiry) {
       Disconnect-PnPOnline
       Connect-PnPOnline -Url $siteUrl -Interactive
   }
   ```

2. **Use app-only authentication** (for automation):
   ```powershell
   Connect-PnPOnline -Url $siteUrl -ClientId "..." -Tenant "..." -CertificatePath "..."
   ```

## PowerShell Script Errors

### Error: "Cannot bind argument to parameter"

**Cause:** Missing required parameter or wrong data type

**Solution:**
```powershell
# Check parameter requirements
Get-Help .\01-Configure-TermStore.ps1 -Detailed

# Provide all mandatory parameters
.\01-Configure-TermStore.ps1 -TenantUrl "https://tenant-admin.sharepoint.com"
```

### Error: "File not found"

**Cause:** Running script from wrong directory or config files missing

**Solution:**
```powershell
# Navigate to scripts directory
cd /path/to/KnowledgePortal/scripts

# Verify config files exist
Test-Path ../config/taxonomy.json
```

### Error: "Execution policy restriction"

**Cause:** PowerShell execution policy blocks script

**Solution:**
```powershell
# Check current policy  
Get-ExecutionPolicy

# Set to RemoteSigned (recommended)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or bypass for single session
powershell.exe -ExecutionPolicy Bypass -File .\Deploy-KnowledgeBase.ps1
```

## Diagnostic Commands

### Check Site Health

```powershell
Connect-PnPOnline -Url "https://tenant.sharepoint.com/sites/kb" -Interactive

# Site information
Get-PnPWeb | Select-Object Title, Url, Created

# Storage usage
Get-PnPWeb | Select-Object StorageUsageCurrent, StorageUsageWarning

# List all lists/libraries
Get-PnPList | Select-Object Title, ItemCount, LastItemModifiedDate
```

### Verify Metadata Configuration

```powershell
# Check columns
Get-PnPField -List "Site Pages" | Where-Object {
    $_.InternalName -in @('KnowledgeCategory','ArticleSummary','LastReviewDate')
} | Select-Object Title, InternalName, TypeAsString

# Check views
Get-PnPView -List "Site Pages" | Select-Object Title, DefaultView
```

### Check Permissions

```powershell
# List all groups
Get-PnPGroup | Select-Object Title, Owner

# Check group permissions
Get-PnPGroupPermissions -Identity "KB Members"

# List site collection admins
Get-PnPSiteCollectionAdmin
```

### Review Activity

```powershell
# Recent page modifications
Get-PnPListItem -List "Site Pages" -Fields "Title","Modified","Editor" |
    Where-Object { $_.FieldValues.Modified -gt (Get-Date).AddDays(-7) } |
    Select-Object @{N='Title';E={$_.FieldValues.Title}}, 
                  @{N='Modified';E={$_.FieldValues.Modified}},
                  @{N='Editor';E={$_.FieldValues.Editor.LookupValue}}
```

## Getting Help

### Log Files

All scripts generate logs in the `logs/` directory:
- **Format:** `[ScriptName]-[Timestamp].log`
- **Location:** `/KnowledgePortal/logs/`
- **Contents:** Timestamped actions, errors, warnings

**Review logs:**
```powershell
# View latest log
Get-Content ./logs/*.log -Tail 50

# Search for errors
Select-String -Path ./logs/*.log -Pattern "ERROR"
```

### Validation Script

Run validation to identify issues:
```powershell
.\Test-KBDeployment.ps1 -SiteUrl "https://tenant.sharepoint.com/sites/kb" -GenerateReport
```

Generates HTML report showing what's working and what's not.

### Support Channels

**Internal Support:**
- Email: kb.admin@company.com
- Teams: Knowledge Base Support Channel
- Office Hours: Tuesdays 2-3 PM

**External Resources:**
- [PnP PowerShell Docs](https://pnp.github.io/powershell/)
- [SharePoint Community](https://techcommunity.microsoft.com/t5/sharepoint/ct-p/SharePoint)
- [Microsoft Support](https://support.microsoft.com/)

---

**Version:** 1.0  
**Last Updated:** 2026-01-05

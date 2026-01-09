# Knowledge Base - Administrator Guide

## Daily Operations

### Monitoring the Knowledge Base

**Check Site Health (Daily)**
- Review SharePoint admin center for alerts
- Monitor storage usage
- Check for failed workflows
- Review recent activity logs

**Access Analytics**
```powershell
Connect-PnPOnline -Url "https://tenant.sharepoint.com/sites/kb" -Interactive
Get-PnPSiteAnalytics
```

### Content Approval Workflow

**Approve Pending Articles**

1. Navigate to Site Pages library
2. Filter view: "Approval Status" = "Pending"
3. Review article content
4. Click "..." > Approve or Reject
5. Add comments for author

**Approval Criteria:**
- Content is accurate and up-to-date
- Follows style guidelines
- Metadata properly tagged
- Images/screenshots included
- No sensitive information exposed

## Taxonomy Management

### Adding New Terms

**Via PowerShell:**
```powershell
Connect-PnPOnline -Url "https://tenant-admin.sharepoint.com" -Interactive

# Add new parent term
Add-PnPTerm -TermSet "KB Structure" -TermGroup "Enterprise Knowledge" -Term "Cybersecurity"

# Add child term
$parent = Get-PnPTerm -TermSet "KB Structure" -Term "Cybersecurity"
Add-PnPTerm -TermSet "KB Structure" -Term "Zero Trust" -Parent $parent
```

**Via SharePoint UI:**
1. Go to SharePoint Admin Center
2. Content Services > Term Store
3. Expand "Enterprise Knowledge" > "KB Structure"
4. Right-click parent term > Create Term
5. Enter term name and save

### Managing Term Properties

- **Description**: Add clear descriptions to help users select correct category
- **Synonyms**: Add alternate names for better search
- **Available for Tagging**: Ensure enabled for all active terms
- **Deprecated**: Mark outdated terms as deprecated (don't delete)

## User Management

### Adding Users to Groups

**KB Visitors (Read-Only Access)**
```powershell
Connect-PnPOnline -Url "https://tenant.sharepoint.com/sites/kb" -Interactive
Add-PnPGroupMember -LoginName "user@company.com" -Identity "KB Visitors"
```

**KB Members (Contributors)**
```powershell
Add-PnPGroupMember -LoginName "user@company.com" -Identity "KB Members"
```

**KB Owners (Administrators)**
```powershell
Add-PnPGroupMember -LoginName "admin@company.com" -Identity "KB Owners"
```

### Removing Users
```powershell
Remove-PnPGroupMember -LoginName "user@company.com" -Identity "KB Members"
```

## Content Management

### Archiving Outdated Content

**Archive Process:**

1. Identify outdated articles (LastReviewDate > 12 months)
2. Create "Archived" folder in Site Pages
3. Move article to Archived folder
4. Update article with "This content is archived" banner
5. Remove from active navigation

**PowerShell Script:**
```powershell
# Get articles not reviewed in 12+ months
$cutoffDate = (Get-Date).AddMonths(-12)
$oldArticles = Get-PnPListItem -List "Site Pages" | Where-Object {
    $_.FieldValues.LastReviewDate -lt $cutoffDate
}

foreach ($article in $oldArticles) {
    Write-Host "Review needed: $($article.FieldValues.Title)"
}
```

### Promoting Important Articles

**Feature on Home Page:**
1. Edit home page
2. Add/edit Hero web part
3. Select article to feature
4. Add compelling image and description
5. Publish

**Add to Quick Links:**
1. Edit page with Quick Links web part
2. Click "Edit web part"
3. Add link to important article
4. Arrange order
5. Save and publish

## Analytics & Reporting

### Monthly Usage Report

**Generate Report:**

```powershell
$siteUrl = "https://tenant.sharepoint.com/sites/kb"
Connect-PnPOnline -Url $siteUrl -Interactive

# Get page views
$pages = Get-PnPListItem -List "Site Pages" -PageSize 500
$report = @()

foreach ($page in $pages) {
    $analytics = Get-PnPPageAnalytics -Identity $page.Id
    $report += [PSCustomObject]@{
        Title = $page.FieldValues.Title
        Views = $analytics.ViewCount
        Category = $page.FieldValues.KnowledgeCategory.Label
        LastModified = $page.FieldValues.Modified
    }
}

$report | Export-Csv -Path "KB-Usage-Report-$(Get-Date -Format 'yyyyMM').csv"
```

### Search Analytics

**Top Search Queries:**
1. SharePoint Admin Center > Reports > Usage
2. Select "SharePoint" > "Search"
3. Filter by KB site
4. Review top queries
5. Identify content gaps

## Maintenance Tasks

### Weekly Tasks
- [ ] Review pending approvals
- [ ] Check for broken links
- [ ] Monitor site storage
- [ ] Review new content submissions

### Monthly Tasks
- [ ] Generate usage report
- [ ] Review search analytics
- [ ] Audit permissions
- [ ] Update outdated content
- [ ] Back up site content

### Quarterly Tasks
- [ ] Term Store audit (add new, deprecate old)
- [ ] Comprehensive content review
- [ ] User group membership review
- [ ] Performance optimization
- [ ] Governance policy review

## Backup & Recovery

### Site Backup

**Manual Backup:**
```powershell
# Export all content
Connect-PnPOnline -Url "https://tenant.sharepoint.com/sites/kb" -Interactive

# Save site template
Get-PnPSiteTemplate -Out "KB-Backup-$(Get-Date -Format 'yyyyMMdd').xml" -IncludeAllPages
```

**Restore from Backup:**
```powershell
Invoke-PnPSiteTemplate -Path "KB-Backup-20260105.xml"
```

### Version History Recovery

1. Navigate to Site Pages library
2. Select article
3. Click "..." > Version History
4. Select version to restore
5. Click "Restore"

## Performance Optimization

### Large Library Management

**Enable Content Approval:**
- Reduces load on library views
- Controls what users see

**Create Indexed Columns:**
```powershell
# Index frequently filtered columns
Set-PnPField -List "Site Pages" -Identity "KnowledgeCategory" -Indexed $true
Set-PnPField -List "Site Pages" -Identity "LastReviewDate" -Indexed $true
```

**Limit View Items:**
- Default views should show <1000 items
- Use filters to reduce returned items

## Security & Compliance

### External Sharing

**Disable External Sharing:**
```powershell
Set-PnPSite -Url "https://tenant.sharepoint.com/sites/kb" -Sharing Disabled
```

### Audit Logging

**Enable Auditing:**
1. Site Settings > Site Collection Administration > Audit Settings
2. Check desired events:
   - Opening or downloading documents
   - Editing items
   - Deleting items
3. Save

**Review Audit Log:**
```powershell
Get-PnPAuditLogReport -StartDate (Get-Date).AddDays(-30)
```

### Sensitivity Labels

Apply sensitivity labels to confidential articles:
1. Enable sensitivity labels in M365 Compliance Center
2. Create labels (Internal, Confidential, etc.)
3. Apply to articles as metadata

## Troubleshooting

### Common Issues

**Issue: Navigation tree not showing**
- Verify metadata navigation configured (Library Settings)
- Check KnowledgeCategory field is populated
- Refresh browser cache

**Issue: Search not returning results**
- Wait 24 hours for new content to be indexed
- Check if article is published (not draft)
- Verify metadata tags applied

**Issue: Users can't access site**
- Check group membership
- Verify permissions not broken accidentally
- Check Azure AD synchronization

### Performance Issues

**Site is slow:**
- Review storage usage (Archive old content)
- Optimize images (compress large files)
- Reduce web parts on home page
- Enable CDN for images

## Best Practices

### Content Governance
- Establish content owners for each category
- Set review cycles (quarterly for active content)
- Require article summaries for searchability
- Enforce metadata tagging before publishing

### Navigation Design
- Keep taxonomy depth to 3 levels maximum
- Use clear, consistent term names
- Group related topics together
- Avoid creating too many top-level categories

### User Adoption
- Train new contributors regularly
- Showcase success stories
- Gather user feedback
- Promote via Teams and email

## Support Resources

- **Microsoft Learn**: [SharePoint Online documentation](https://learn.microsoft.com/)
- **PnP PowerShell**: [Documentation](https://pnp.github.io/powershell/)
- **Community**: [SharePoint Tech Community](https://techcommunity.microsoft.com/t5/sharepoint/ct-p/SharePoint)

---

**Version:** 1.0  
**Last Updated:** 2026-01-05

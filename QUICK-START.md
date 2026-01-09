# SharePoint Knowledge Base - Quick Deployment Reference

## 🚀 Quick Start (20 Minutes)

### Prerequisites
- [ ] SharePoint Administrator role
- [ ] PowerShell 5.1+ or PowerShell 7
- [ ] Internet connection

### 1. Install PnP PowerShell (2 min)
```powershell
Install-Module -Name PnP.PowerShell -Force -Scope CurrentUser
```

### 2. Customize Config Files (5 min)
**Edit these files in `config/` folder:**
- `site-config.json` - Change owner email and URL alias
- `permissions.json` - Update Azure AD group names
- `taxonomy.json` - Add your categories (optional)

### 3. Deploy (15 min)
```powershell
cd KnowledgePortal\scripts

# Dry run (recommended first)
.\Deploy-KnowledgeBase.ps1 -TenantUrl "https://TENANT-admin.sharepoint.com" -WhatIf

# Actual deployment
.\Deploy-KnowledgeBase.ps1 -TenantUrl "https://TENANT-admin.sharepoint.com"
```

### 4. Manual Step (5 min)
1. Go to Site Pages library
2. Library Settings → Metadata navigation settings
3. Add "Knowledge Category" to Navigation Hierarchies
4. Save

### 5. Validate (2 min)
```powershell
.\Test-KBDeployment.ps1 -SiteUrl "https://TENANT.sharepoint.com/sites/kb" -GenerateReport
```

---

## 📝 Command Cheat Sheet

### Deploy
```powershell
.\Deploy-KnowledgeBase.ps1 -TenantUrl "https://TENANT-admin.sharepoint.com"
```

### Create Article
```powershell
.\New-KBArticle.ps1 -SiteUrl "https://TENANT.sharepoint.com/sites/kb"
```

### Import Bulk Content
```powershell
.\Import-BulkContent.ps1 -SiteUrl "https://TENANT.sharepoint.com/sites/kb" -SourceFile "articles.csv"
```

### Validate
```powershell
.\Test-KBDeployment.ps1 -SiteUrl "https://TENANT.sharepoint.com/sites/kb" -GenerateReport
```

### Cleanup/Rollback
```powershell
.\Remove-KBDeployment.ps1 -SiteUrl "https://TENANT.sharepoint.com/sites/kb"
```

---

## 🔧 Configuration Files Reference

| File | Purpose | Key Settings |
|------|---------|-------------|
| `taxonomy.json` | Category structure | Add your terms under "terms" array |
| `site-config.json` | Site settings | owner, urlAlias, timeZone |
| `permissions.json` | Security groups | azureADGroups, users arrays |
| `template-pages.json` | Page templates | Usually no changes needed |

---

## 📂 Project Structure

```
KnowledgePortal/
├── scripts/        → PowerShell automation
├── config/         → Customize these!
├── docs/           → Documentation
├── admin-portal/   → Optional web UI
└── logs/           → Created during deployment
```

---

## ⚠️ Important Notes

1. **Replace TENANT** with your actual tenant name in all commands
2. **Run PowerShell as Administrator**
3. **Metadata navigation** must be configured manually (Step 4)
4. **Azure AD groups** in permissions.json must match your actual groups
5. **Log files** saved to `logs/` folder for troubleshooting

---

## 🆘 Quick Troubleshooting

| Issue | Solution |
|-------|----------|
| Access Denied | Verify SharePoint Admin role |
| Module not found | Install PnP PowerShell (step 1) |
| Term Store error | Add yourself as Term Store Administrator |
| Navigation tree missing | Complete manual metadata navigation setup |
| Permission errors | Update Azure AD groups in permissions.json |

---

## 📚 Documentation

- **Full Deployment:** `docs/step-by-step-deployment-guide.md`
- **Administrator:** `docs/administrator-guide.md`
- **Contributors:** `docs/content-contributor-guide.md`
- **Troubleshooting:** `docs/troubleshooting-guide.md`

---

## 🎯 Success Checklist

After deployment, verify:
- [ ] Site accessible at https://TENANT.sharepoint.com/sites/kb
- [ ] Metadata navigation tree visible in Site Pages
- [ ] Security groups created (KB Visitors, Members, Owners)
- [ ] Template pages exist
- [ ] Validation script reports 100% success
- [ ] Can create test article
- [ ] Teams tab added

---

**Need detailed instructions?** See `step-by-step-deployment-guide.md`

**Version:** 1.0 | **Updated:** 2026-01-09

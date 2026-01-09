# SharePoint Enterprise Knowledge Base

![Knowledge Base](https://img.shields.io/badge/SharePoint-Online-blue) ![PowerShell](https://img.shields.io/badge/PowerShell-7.0+-green) ![License](https://img.shields.io/badge/License-MIT-yellow)

## Overview

A complete, production-ready SharePoint Online Knowledge Base solution featuring:

- **Automated Deployment**: PowerShell scripts to configure everything automatically
- **Metadata-Driven Architecture**: Flat structure with managed metadata for scalability
- **Teams Integration**: Native Microsoft Teams tab support
- **Comprehensive Documentation**: Step-by-step guides for deployment, administration, and content creation
- **Enterprise-Ready**: Governance framework, permissions model, and approval workflows

## Features

✨ **Key Capabilities:**

- Hierarchical navigation with expandable term tree
- Rich content pages with text, images, videos, and code blocks
- Metadata tagging for powerful search and filtering
- Card/Gallery view for visual content discovery
- Content approval workflow
- Version control and audit trail
- Mobile-responsive design
- Analytics and reporting

## Quick Start

### Prerequisites

- SharePoint Online (Microsoft 365)
- PowerShell 5.1 or later
- PnP PowerShell module
- SharePoint Administrator role

### Installation

1. **Install PnP PowerShell:**
   ```powershell
   Install-Module -Name PnP.PowerShell -Force -AllowClobber
   ```

2. **Clone or download this repository**

3. **Configure settings:**
   - Edit `config/taxonomy.json` - Define your taxonomy hierarchy
   - Edit `config/site-config.json` - Set site URL, owner, branding
   - Edit `config/permissions.json` - Configure security groups and members

4. **Deploy:**
   ```powershell
   cd KnowledgePortal/scripts
   
   # Run master deployment script
   .\Deploy-KnowledgeBase.ps1 -TenantUrl "https://yourtenant-admin.sharepoint.com"
   ```

5. **Validate:**
   ```powershell
   .\Test-KBDeployment.ps1 -SiteUrl "https://yourtenant.sharepoint.com/sites/kb" -GenerateReport
   ```

📖 **For detailed step-by-step instructions with screenshots:** See [Step-by-Step Deployment Guide](docs/step-by-step-deployment-guide.md)

🚀 **For quick reference:** See [QUICK-START.md](QUICK-START.md)

## Project Structure

```
KnowledgePortal/
├── scripts/                          # PowerShell automation scripts
│   ├── 01-Configure-TermStore.ps1   # Term Store setup
│   ├── 02-Create-CommunicationSite.ps1  # Site provisioning
│   ├── 03-Setup-Metadata.ps1        # Metadata columns
│   ├── 04-Configure-Permissions.ps1 # Security groups
│   ├── 05-Setup-Navigation.ps1      # Navigation configuration
│   ├── 06-Deploy-Templates.ps1      # Page templates
│   ├── Deploy-KnowledgeBase.ps1     # Master orchestration
│   ├── New-KBArticle.ps1            # Create new articles
│   ├── Import-BulkContent.ps1       # Bulk content migration
│   ├── Test-KBDeployment.ps1        # Validation script
│   └── Remove-KBDeployment.ps1      # Cleanup/rollback
│
├── config/                           # Configuration files
│   ├── taxonomy.json                 # Term hierarchy definition
│   ├── site-config.json             # Site settings and branding
│   ├── permissions.json             # Security groups and permissions
│   └── template-pages.json          # Page template definitions
│
├── docs/                             # Documentation
│   ├── deployment-runbook.md        # Step-by-step deployment guide
│   ├── administrator-guide.md       # Admin operations manual
│   ├── content-contributor-guide.md # Content creation guide
│   ├── governance-framework.md      # Governance policies
│   └── troubleshooting-guide.md     # Common issues and solutions
│
├── admin-portal/                     # Optional web-based admin portal
│   ├── index.html                    # Admin dashboard
│   ├── styles/                       # CSS files
│   └── scripts/                      # JavaScript files
│
├── logs/                             # Script execution logs (generated)
└── README.md                         # This file
```

## Usage

### Creating Content

**Interactive Method:**
```powershell
.\New-KBArticle.ps1 -SiteUrl "https://yourtenant.sharepoint.com/sites/kb"
```

**Command-Line Method:**
```powershell
.\New-KBArticle.ps1 `
    -SiteUrl "https://yourtenant.sharepoint.com/sites/kb" `
    -Title "How to Enable Teams Meetings" `
    -Summary "Step-by-step guide for enabling meetings in Teams" `
    -Category "M365/Teams" `
    -PublishImmediately
```

### Bulk Content Import

```powershell
.\Import-BulkContent.ps1 `
    -SiteUrl "https://yourtenant.sharepoint.com/sites/kb" `
    -SourceFile "./articles.csv" `
    -PublishArticles
```

**CSV Format:**
```csv
Title,Summary,Category,Content
"Article 1","Brief summary","M365/Teams","Full article content..."
"Article 2","Another summary","AI/Copilot Chat","More content..."
```

### Teams Integration

1. Open Microsoft Teams
2. Navigate to desired channel
3. Click "+" to add tab
4. Select "SharePoint"
5. Choose your Knowledge Base site
6. Name: "Knowledge Base"
7. Save

## Configuration

### Taxonomy Customization

Edit `config/taxonomy.json` to define your categories:

```json
{
  "terms": [
    {
      "name": "YourCategory",
      "children": [
        {"name": "SubCategory1"},
        {"name": "SubCategory2"}
      ]
    }
  ]
}
```

### Permissions

Edit `config/permissions.json` to configure access:

| Group | Permission | Purpose |
|-------|-----------|---------|
| KB Visitors | Read | View KB content |
| KB Members | Edit | Create and edit articles |
| KB Owners | Full Control | Administer KB |

## Administration

### Daily Tasks
- Review pending article approvals
- Monitor site health
- Check for broken links

### Monthly Tasks
- Generate usage reports
- Review analytics
- Update outdated content
- Audit permissions

See [Administrator Guide](docs/administrator-guide.md) for complete details.

## Troubleshooting

### Common Issues

**Scripts fail with "Access Denied"**
- Verify SharePoint Administrator role
- Check site owner permissions
- See [Troubleshooting Guide](docs/troubleshooting-guide.md)

**Navigation tree not showing**
- Manual configuration required (one-time)
- Follow steps in [Deployment Runbook](docs/deployment-runbook.md#step-6)

**Search not returning results**
- Wait 24 hours for indexing
- Verify articles are published (not drafts)
- Check metadata tags applied

## Documentation

| Document | Description |
|----------|-------------|
| [**Step-by-Step Deployment Guide**](docs/step-by-step-deployment-guide.md) | ⭐ Detailed guide with screenshots for deploying to SharePoint Online |
| [Quick Start](QUICK-START.md) | Quick reference card for rapid deployment |
| [Deployment Runbook](docs/deployment-runbook.md) | Technical deployment instructions and procedures |
| [Administrator Guide](docs/administrator-guide.md) | Daily operations and maintenance |
| [Content Contributor Guide](docs/content-contributor-guide.md) | Creating and managing articles |
| [Governance Framework](docs/governance-framework.md) | Policies and procedures |
| [Troubleshooting Guide](docs/troubleshooting-guide.md) | Common issues and solutions |

## Architecture

### Information Architecture

**Flat Structure with Managed Metadata:**
- All pages in single library (Site Pages)
- Virtual hierarchy via taxonomy
- Avoids folder nesting issues
- Scalable to thousands of articles

### Technology Stack

- **Platform**: SharePoint Online (Communication Site)
- **Automation**: PnP PowerShell
- **Metadata**: Managed Metadata Service (Term Store)
- **Search**: SharePoint Search with metadata filtering
- **Integration**: Microsoft Teams, Microsoft 365

### Security Model

- **Authentication**: Azure AD / Microsoft 365
- **Authorization**: SharePoint groups and permission levels
- **External Sharing**: Disabled by default
- **Compliance**: Audit logging, version history, retention policies

## Roadmap

- [ ] Power Automate approval workflows
- [ ] Advanced analytics dashboard
- [ ] AI-powered content recommendations
- [ ] Multi-language support
- [ ] Integration with Microsoft Graph API
- [ ] Mobile app for offline access

## Contributing

### Content Contributions
Follow the [Content Contributor Guide](docs/content-contributor-guide.md)

### Code Contributions
1. Fork the repository
2. Create feature branch
3. Submit pull request
4. Ensure scripts follow existing patterns

## Support

- **Internal**: kb.admin@company.com
- **Community**: [SharePoint Tech Community](https://techcommunity.microsoft.com/t5/sharepoint/ct-p/SharePoint)
- **Documentation**: [Microsoft SharePoint Docs](https://learn.microsoft.com/en-us/sharepoint/)

## License

MIT License - See LICENSE file for details

## Acknowledgments

- Based on Microsoft SharePoint Online best practices
- Powered by [PnP PowerShell](https://pnp.github.io/powershell/)
- Inspired by enterprise knowledge management patterns

---

**Version:** 1.0.0  
**Author:** Jyotirmoy Bhowmik  
**Last Updated:** 2026-01-05  

**🚀 Ready to deploy your enterprise knowledge base!**

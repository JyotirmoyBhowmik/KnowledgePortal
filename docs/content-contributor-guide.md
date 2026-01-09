# Knowledge Base - Content Contributor Guide

## Getting Started

Welcome to the Knowledge Base! This guide will help you create and manage high-quality knowledge articles.

### What is the Knowledge Base?

The Knowledge Base (KB) is our centralized repository for:
- Technology guides and tutorials
- Process documentation
- Standard operating procedures (SOPs)
- Best practices and tips

### Who Can Contribute?

If you're a member of the **KB Members** group, you can create and edit articles. Contact your KB administrator if you need access.

## Creating Your First Article

### Quick Method: Using the Helper Script

The easiest way to create an article is with PowerShell:

```powershell
.\New-KBArticle.ps1 `
    -SiteUrl "https://tenant.sharepoint.com/sites/kb" `
    -Title "How to Reset Your Password" `
    -Summary "Step-by-step guide for resetting passwords" `
    -Category "Security/Identity Management"
```

The script will:
1. Create the page from a template
2. Set metadata automatically
3. Open the page in your browser for editing

### Manual Method: SharePoint UI

**Step 1: Navigate to KB Site**
- Go to: `https://[tenant].sharepoint.com/sites/kb`
- Click on **Site Pages** in the left navigation

**Step 2: Create New Page**
- Click **+ New** > **Site Page**
- Choose page template (usually "Blank" or "Article")
- Get started!

**Step 3: Add Title and Content**
- Enter a clear, descriptive title
- Use the + icon to add content sections:
  - **Text**: For paragraphs and instructions
  - **Image**: For screenshots
  - **List**: For numbered/bulleted lists
  - **Quote**: For important callouts

**Step 4: Set Metadata**
- On the right panel, click "..." > **Page details**
- Fill in required fields:
  - **Article Summary**: Brief description (2-3 sentences)
  - **Knowledge Category**: Select from dropdown
  - **Last Review Date**: Set to today

**Step 5: Publish**
- Click **Save as draft** (to save without publishing)
- OR **Publish** (to make live immediately)
- If approval is enabled, click **Submit for approval**

## Content Guidelines

### Writing Style

**Use Clear Language**
- Write for an 8th-grade reading level
- Avoid jargon unless necessary
- Define acronyms on first use

**Be Concise**
- Get to the point quickly
- Use short paragraphs (2-4 sentences)
- Break up long content with headings

**Use Active Voice**
- ✅ "Click the Submit button"
- ❌ "The Submit button should be clicked"

### Recommended Structure

Every article should follow this template:

```markdown
# [Article Title]

## Overview
Brief introduction (2-3 sentences) explaining what this guide covers and who it's for.

## Prerequisites
- List what users need before starting
- Required permissions
- Software or access requirements

## Step-by-Step Instructions

### Step 1: [Action]
1. Detailed instruction
2. Include screenshots
3. Mention expected results

### Step 2: [Action]
1. Continue with clear steps
2. Number sequentially

## Tips & Best Practices
- Helpful hints
- Common shortcuts
- Recommendations

## Common Issues
- Problem: Description
  - **Solution**: How to resolve

## Related Articles
- Links to related KB articles
```

### Screenshots & Images

**When to Include Screenshots:**
- UI-heavy procedures
- Complex configurations
- Visual references

**Screenshot Best Practices:**
- Use annotation tools to highlight key areas (red boxes/arrows)
- Crop to show only relevant portions
- Keep file size under 500KB (compress if needed)
- Use standard naming: `[topic]-[step]-screenshot.png`

**Adding Images:**
1. Click + where you want the image
2. Select **Image**
3. Upload from your computer or OneDrive
4. Add alt text for accessibility
5. Resize as needed

### Formatting Tips

**Headings:**
- H1: Page title only (automatic)
- H2: Major sections
- H3: Sub-sections
- Don't skip levels (e.g., H1 to H3)

**Lists:**
- Use numbered lists for sequential steps
- Use bulleted lists for options or features
- Keep lists parallel in structure

**Code Blocks:**
- Use for commands, scripts, or code samples
- Click + > Embed > Code
- Specify language for syntax highlighting

**Tables:**
- Great for reference information
- Keep simple (3-5 columns max)
- Include header row

## Metadata & Categorization

### Knowledge Category

Choose the most specific category that applies:

**M365 Topics:**
- M365/Teams
- M365/OneDrive
- M365/SharePoint
- M365/Outlook

**AI & Copilot:**
- AI/Copilot Chat
- AI/Copilot Pro
- AI/Copilot in M365

**Development:**
- Development/Azure DevOps
- Development/GitHub
- Development/Power Platform

**Security:**
- Security/Identity Management
- Security/Data Protection
- Security/Compliance

### Article Summary

Write a 2-3 sentence summary that answers:
- What does this article cover?
- Who is it for?
- What will they learn?

**Example:**
> "This guide explains how to enable external sharing on OneDrive for Business. IT administrators will learn the step-by-step process to configure sharing settings and apply policies. Includes security best practices and common troubleshooting steps."

### Last Review Date

- Set to today's date when creating
- Update whenever you review/edit the article
- Helps identify outdated content

## Collaboration

### Mentioning Colleagues

Tag subject matter experts for review:
1. Type `@` in the page
2. Start typing a name
3. Select from dropdown
4. They'll receive a notification

### Comments
- Use comments to ask questions or provide feedback
- Click "..." on any section > **Comment**
- Resolve comments when addressed

### Version History

Every save creates a version:
- View history: **...** > **Version history**
- Compare versions
- Restore previous version if needed

## Content Lifecycle

### Review Cycle

Articles should be reviewed:
- **Quarterly**: For frequently changing topics (software features)
- **Annually**: For stable topics (processes, policies)

When reviewing:
1. Verify information is still accurate
2. Update screenshots if UI changed
3. Add new tips or workarounds
4. Update **Last Review Date**

### Archiving Content

If content is no longer relevant:
- Add banner: "⚠️ This article is archived. See [newer article]."
- Move to "Archived" folder (contact admin)
- Don't delete (preserves historical reference)

## Quality Checklist

Before publishing, verify:

- [ ] Title is clear and descriptive
- [ ] Content follows the recommended structure
- [ ] All steps are numbered sequentially
- [ ] Screenshots are annotated and compressed
- [ ] Spelling and grammar checked
- [ ] Links work and go to correct destinations
- [ ] Article Summary is complete
- [ ] Knowledge Category is set
- [ ] Last Review Date is current
- [ ] Related articles linked
- [ ] Tested instructions in safe environment

## Tips for Success

### Make it Scannable
- Use headings to break up content
- Bold key terms
- Use bullet points
- Add callout boxes for warnings

### Keep it Current
- Review your articles quarterly
- Update when products change
- Archive outdated content

### Learn from Analytics
- Check which articles are popular
- See what users search for
- Fill content gaps

### Get Feedback
- Ask users if articles are helpful
- Enable comments for questions
- Iterate based on feedback

## Need Help?

**Contact KB Administrators:**
- Email: kb.admin@company.com
- Teams: Knowledge Base Channel

**Resources:**
- [SharePoint Page Authoring Guide](https://learn.microsoft.com/)
- [Accessibility Best Practices](https://www.microsoft.com/)
- [Writing Style Guide](internal link)

---

**Version:** 1.0  
**Last Updated:** 2026-01-05  
**Happy Writing! 📝**

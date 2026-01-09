# SharePoint Knowledge Base - Manual Deployment Guide (Browser Only)

## 📖 Complete Guide for Deploying Without PowerShell

This guide provides step-by-step instructions for deploying the SharePoint Knowledge Base using **only the web browser interface** - no PowerShell required.

**Time Required:** 2-3 hours  
**Difficulty:** Beginner to Intermediate  
**Prerequisites:** SharePoint Administrator role

---

## 📋 Table of Contents

1. [Create Communication Site](#step-1-create-communication-site)
2. [Configure Term Store Taxonomy](#step-2-configure-term-store-taxonomy)
3. [Setup Site Pages Library Columns](#step-3-setup-site-pages-library-columns)
4. [Configure Metadata Navigation](#step-4-configure-metadata-navigation)
5. [Create Security Groups & Permissions](#step-5-create-security-groups--permissions)
6. [Create Page Templates](#step-6-create-page-templates)
7. [Design Home Page](#step-7-design-home-page)
8. [Upload Site Logo](#step-8-upload-site-logo)
9. [Integrate with Microsoft Teams](#step-9-integrate-with-microsoft-teams)
10. [Create First Article](#step-10-create-first-article)
11. [Add Users](#step-11-add-users)

---

## Step 1: Create Communication Site

**Time:** 10 minutes

### 1.1 Access SharePoint Home

1. Open your web browser (Chrome, Edge, or Firefox recommended)
2. Navigate to: **https://[yourtenant].sharepoint.com**
   - Replace `[yourtenant]` with your organization's tenant name
   - Example: `https://contoso.sharepoint.com`
3. Sign in with your Microsoft 365 account

**Screenshot Guide:**
```
[You should see the SharePoint start page with "Create site" button]
```

### 1.2 Create New Communication Site

1. Click **+ Create site** button (top of page)

2. **Select site type:**
   - Click **Communication site**
   
   **Screenshot:**
   ```
   [Dialog showing options: Team site, Communication site]
   ```

3. **Choose template:**
   - Select **Topic** (recommended for Knowledge Base)
   - Click **Use template**
   
   **Available templates:**
   - **Topic** ⭐ (Best for KB - organized content)
   - **Showcase** (For visual storytelling)
   - **Blank** (Start from scratch)

### 1.3 Configure Site Settings

**Site name:**
```
IT Knowledge Base
```

**Site description:**
```
Centralized repository for IT documentation, guides, and standard operating procedures
```

**Site address:**
- You'll see: `https://[yourtenant].sharepoint.com/sites/`
- **Enter:** `kb` (or your preferred URL)
- Full URL will be: `https://[yourtenant].sharepoint.com/sites/kb`

**Language:**
- Select your preferred language (e.g., English)

**Time zone:**
- Select your time zone
- Example: (UTC-05:00) Eastern Time (US & Canada)

**Screenshot:**
```
[Form showing site name, description, address, language, and time zone fields]
```

4. Click **Finish**

5. **Wait for site creation** (30-60 seconds)
   - You'll see a loading screen
   - Site will open automatically when ready

### 1.4 Verify Site Creation

You should now see your new Communication Site with:
- Site header with title "IT Knowledge Base"
- Default home page with sample content
- Navigation menu on the left
- Settings gear icon (⚙️) on the top right

**Screenshot:**
```
[New Communication Site homepage showing default layout]
```

✅ **Step 1 Complete!** Your site is created at: `https://[yourtenant].sharepoint.com/sites/kb`

---

## Step 2: Configure Term Store Taxonomy

**Time:** 30 minutes

### 2.1 Access Term Store

1. **Navigate to SharePoint Admin Center:**
   - Open new browser tab
   - Go to: **https://[yourtenant]-admin.sharepoint.com**
   - Example: `https://contoso-admin.sharepoint.com`
   - Sign in if prompted

2. **Open Term Store:**
   - In left navigation, click **Content services**
   - Click **Term store**

**Screenshot:**
```
[SharePoint Admin Center left navigation showing Content services expanded]
```

### 2.2 Create Term Group

1. **Create new term group:**
   - In the Term Store
   - Look for the taxonomy tree on the left
   - Click the **down arrow** next to "Managed Metadata Service"
   - Select **New Group**

2. **Name the group:**
   - Type: `Enterprise Knowledge`
   - Press Enter

**Screenshot:**
```
[Term Store interface showing "New Group" option in dropdown menu]
```

### 2.3 Configure Term Group Settings

1. Click on **Enterprise Knowledge** (the group you just created)

2. **In the properties pane (right side):**
   - **Description:** `Term group for Knowledge Base taxonomy`
   - **Group Managers:** Add yourself and other administrators
   - Click **Save**

### 2.4 Create Term Set

1. **Create the term set:**
   - Right-click **Enterprise Knowledge** group
   - Select **New Term Set**

2. **Name it:**
   - Type: `KB Structure`
   - Press Enter

3. **Configure term set properties:**
   - Click **KB Structure** to select it
   - In the properties pane (right):
     - **Description:** `Hierarchical structure for Knowledge Base navigation`
     - **Owner:** Your email address
     - **Contact:** IT team email (e.g., `kb.admin@company.com`)
     - **Submission Policy:** Select **Closed** (only administrators can add terms)
     - **Available for Tagging:** ✓ Checked
   - Click **Save**

**Screenshot:**
```
[Term set properties showing all fields filled]
```

### 2.5 Create Taxonomy Hierarchy

Now we'll create the category structure. We'll create 4 main categories with sub-categories.

#### Category 1: M365

1. **Create parent term:**
   - Right-click **KB Structure**
   - Select **Create Term**
   - Name: `M365`
   - Press Enter

2. **Add properties:**
   - With M365 selected
   - Description: `Microsoft 365 Applications and Services`
   - Available for Tagging: ✓ Checked
   - Click **Save**

3. **Create child terms under M365:**
   - Right-click **M365**
   - Select **Create Term**
   - Name: `Teams`
   - Press Enter
   
   Repeat for:
   - `OneDrive`
   - `SharePoint`
   - `Outlook`

**Your structure should look like:**
```
▼ KB Structure
  ▼ M365
    - Teams
    - OneDrive
    - SharePoint
    - Outlook
```

#### Category 2: AI

1. Right-click **KB Structure**
2. Select **Create Term**
3. Name: `AI`
4. Add description: `Artificial Intelligence and Copilot`

**Create children:**
- `Copilot Chat`
- `Copilot Pro`
- `Copilot in M365`

#### Category 3: Development

1. Right-click **KB Structure**
2. Create Term: `Development`
3. Description: `Software Development and DevOps`

**Create children:**
- `Azure DevOps`
- `GitHub`
- `Power Platform`

#### Category 4: Security

1. Right-click **KB Structure**
2. Create Term: `Security`
3. Description: `Security and Compliance`

**Create children:**
- `Identity Management`
- `Data Protection`
- `Compliance`

### 2.6 Verify Complete Taxonomy

Your final structure should look like:

```
▼ Enterprise Knowledge (Group)
  ▼ KB Structure (Term Set)
    ▼ M365
      - Teams
      - OneDrive
      - SharePoint
      - Outlook
    ▼ AI
      - Copilot Chat
      - Copilot Pro
      - Copilot in M365
    ▼ Development
      - Azure DevOps
      - GitHub
      - Power Platform
    ▼ Security
      - Identity Management
      - Data Protection
      - Compliance
```

**Screenshot:**
```
[Complete taxonomy tree showing all categories and subcategories]
```

✅ **Step 2 Complete!** Taxonomy structure is configured.

**⚠️ Important:** Wait 5-10 minutes for taxonomy to propagate before proceeding to next step.

---

## Step 3: Setup Site Pages Library Columns

**Time:** 20 minutes

### 3.1 Access Site Pages Library

1. Return to your Knowledge Base site tab
2. Click the **Settings gear ⚙️** (top right)
3. Click **Site contents**
4. Click **Site Pages**

**Screenshot:**
```
[Site contents page showing Site Pages library]
```

### 3.2 Access Library Settings

1. In Site Pages library
2. Click **Settings gear ⚙️**
3. Click **Library settings**

**Screenshot:**
```
[Library ribbon with Settings option highlighted]
```

### 3.3 Create Column 1: Knowledge Category (Managed Metadata)

1. **Start creating column:**
   - Scroll to **Columns** section
   - Click **Create column**

2. **Configure column:**
   - **Column name:** `Knowledge Category`
   - **Type:** Select **Managed Metadata**
   
   **Screenshot:**
   ```
   [Column type radio buttons with "Managed Metadata" selected]
   ```

3. **Managed Metadata Settings:**
   
   **Description:**
   ```
   Taxonomy classification for knowledge articles
   ```
   
   **Require this column:** No (◯)
   
   **Multiple values:** No (◯)
   
   **Display format:** ● Term Label (not Term Path)
   
   **Customize your term set:**
   - Click **Customize your term set**
   - Click **Use a managed term set**
   - Navigate: **Enterprise Knowledge** → **KB Structure**
   - Select **KB Structure**
   
   **Screenshot:**
   ```
   [Term set picker showing KB Structure selected]
   ```

4. Click **OK**

### 3.4 Create Column 2: Article Summary

1. Click **Create column** again

2. **Configure:**
   - **Column name:** `Article Summary`
   - **Type:** Select **Multiple lines of text**
   - **Description:** `Brief summary of the article for search and card view`
   - **Require this column:** Yes (●)
   - **Number of lines:** `3`
   - **Text type:** ◯ Plain text

3. Click **OK**

### 3.5 Create Column 3: Last Review Date

1. Click **Create column**

2. **Configure:**
   - **Column name:** `Last Review Date`
   - **Type:** Select **Date and Time**
   - **Description:** `Date when article was last reviewed or updated`
   - **Require this column:** No (◯)
   - **Date and Time Format:** ● Date Only
   - **Default value:** ● Today's Date

3. Click **OK**

### 3.6 Verify Columns Created

1. Still in Library Settings
2. Scroll to **Columns** section
3. You should see these custom columns:
   - ✓ Knowledge Category
   - ✓ Article Summary
   - ✓ Last Review Date

**Screenshot:**
```
[Columns list showing the three new custom columns]
```

✅ **Step 3 Complete!** Custom metadata columns are created.

---

## Step 4: Configure Metadata Navigation

**Time:** 5 minutes

### 4.1 Enable Metadata Navigation

1. **Still in Library Settings** (Site Pages)
2. Scroll down to **General Settings**
3. Click **Metadata navigation settings**

### 4.2 Configure Navigation Hierarchies

You'll see two sections:
- **Available Hierarchy Fields** (left box)
- **Selected Hierarchy Fields** (right box)

**Steps:**
1. In **Available Hierarchy Fields**, find **Knowledge Category**
2. Click on **Knowledge Category** to select it
3. Click the **Add >>** button
4. Knowledge Category moves to **Selected Hierarchy Fields**

**Screenshot:**
```
[Metadata navigation page showing Knowledge Category in Selected Hierarchy Fields]
```

### 4.3 Configure Key Filters (Optional)

**Recommended filters to add:**

1. In **Available Key Filter Fields**, find **Modified**
2. Click **Modified**
3. Click **Add >>**

Repeat for:
- **Last Review Date**
- **Author**

### 4.4 Save Configuration

1. Click **OK** at bottom of page
2. You'll return to Site Pages library

### 4.5 Verify Navigation Tree

1. Look at the left side of Site Pages library
2. You should see a section: **Knowledge Category**
3. Click the arrows to expand categories

**Expected view:**
```
▼ Knowledge Category
  ▶ M365
  ▶ AI
  ▶ Development
  ▶ Security
```

**Screenshot:**
```
[Site Pages library with metadata navigation tree on left]
```

**Note:** Categories will be empty until you create articles.

✅ **Step 4 Complete!** Metadata navigation is configured.

---

## Step 5: Create Security Groups & Permissions

**Time:** 15 minutes

### 5.1 Break Permission Inheritance

1. **Navigate to site permissions:**
   - Click **Settings gear ⚙️**
   - Click **Site permissions**

2. **Break inheritance:**
   - Click **Advanced permissions settings** (at bottom)
   - In the ribbon, click **Stop Inheriting Permissions**
   - Click **OK** to confirm

**Screenshot:**
```
[Ribbon showing Stop Inheriting Permissions button]
```

### 5.2 Create Group 1: KB Visitors (Read-Only)

1. **Create new group:**
   - Click **Create Group** in the ribbon

2. **Group settings:**
   - **Name:** `KB Visitors`
   - **Description:** `Read-only access to knowledge base content`
   
   **Group owner:** Your email
   
   **Group Settings:**
   - Who can view membership: ● Everyone
   - Who can edit membership: ◯ Group Owner
   
   **Membership Requests:**
   - ◯ Yes (Allow requests) OR ◯ No (depends on your preference)
   
   **Give Group Permission:**
   - Check ✓ **Read**
   
3. Click **Create**

### 5.3 Create Group 2: KB Members (Contributors)

1. Click **Create Group** again

2. **Settings:**
   - **Name:** `KB Members`
   - **Description:** `Content contributors who can create and edit articles`
   - **Owner:** Your email
   - **Who can view:** ● Everyone
   - **Who can edit:** ◯ Group Owner
   - **Permission:** Check ✓ **Edit**

3. Click **Create**

### 5.4 Create Group 3: KB Owners (Administrators)

1. Click **Create Group**

2. **Settings:**
   - **Name:** `KB Owners`
   - **Description:** `Knowledge Base administrators with full control`
   - **Owner:** Your email
   - **Permission:** Check ✓ **Full Control**

3. Click **Create**

### 5.5 Add Members to Groups

#### Add Everyone to KB Visitors

1. Click **KB Visitors** group
2. Click **New** → **Add Users to this group**
3. In the share box, type: `Everyone except external users`
4. Click **Share**

**This gives all internal employees read access.**

#### Add Contributors to KB Members

1. Click back arrow to permissions page
2. Click **KB Members**
3. Click **New** → **Add Users**
4. Type names or emails:
   - Individual users: `john.doe@company.com`
   - OR Azure AD groups: `IT-Staff@company.com`
5. Click **Share**

#### Add Admins to KB Owners

1. Click **KB Owners**
2. Click **New** → **Add Users**
3. Add administrator accounts
4. Click **Share**

### 5.6 Verify Permissions

1. Go back to main Permissions page
2. You should see:
   - ✓ KB Visitors - Read
   - ✓ KB Members - Edit
   - ✓ KB Owners - Full Control

**Screenshot:**
```
[Permissions page showing all three groups with their permission levels]
```

✅ **Step 5 Complete!** Security groups and permissions configured.

---

## Step 6: Create Page Templates

**Time:** 30 minutes

### 6.1 Create Master Article Template

1. **Navigate to Site Pages:**
   - Go to **Site contents** → **Site Pages**

2. **Create new page:**
   - Click **+ New** → **Site Page**

3. **Choose layout:**
   - Select **Article** layout
   - Page editor opens

### 6.2 Design Template Structure

1. **Set page title:**
   - Click in title area
   - Type: `TEMPLATE - Master Article`

2. **Add Overview Section:**
   - Click **+** to add section
   - Select **One column** section
   - Click **+** in the section
   - Select **Text** web part
   - Type:
   ```
   ## Overview
   
   Provide a brief introduction to this topic. Explain what the reader will learn and why it matters.
   ```

3. **Add Prerequisites Section:**
   - Add another **One column** section
   - Add **Text** web part
   - Type:
   ```
   ## Prerequisites
   
   - Prerequisite 1
   - Prerequisite 2
   - Prerequisite 3
   ```

4. **Add Step-by-Step Section:**
   - Add **One column** section
   - Add **Text** web part
   - Type:
   ```
   ## Step-by-Step Instructions
   
   ### Step 1: [Action]
   Detailed instructions for step 1...
   
   ### Step 2: [Action]
   Detailed instructions for step 2...
   
   ### Step 3: [Action]
   Detailed instructions for step 3...
   ```

5. **Add Tips & Common Issues (Two columns):**
   - Add **Two column** section
   - **Left column - Text web part:**
   ```
   ## 💡 Tips & Best Practices
   
   - Tip 1
   - Tip 2
   - Tip 3
   ```
   
   - **Right column - Text web part:**
   ```
   ## ⚠️ Common Issues
   
   - Issue 1 and solution
   - Issue 2 and solution
   ```

6. **Add Related Articles:**
   - Add **One column** section
   - Add **Text** web part
   - Type:
   ```
   ## Related Articles
   
   Add links to related knowledge base articles here.
   ```

### 6.3 Save Template

1. Click **Save as draft** (top right)
2. **Do NOT publish** - keep as draft template

### 6.4 Set Page Properties

1. Click **...** (top right) → **Page details**

2. **Fill in:**
   - **Article Summary:** `Template for standard knowledge base articles`
   - **Knowledge Category:** Leave blank (will be set per article)
   - **Last Review Date:** Today's date

3. Click **Save**

4. **Note the URL:**
   - Copy the URL from browser
   - Should be: `.../SitePages/TEMPLATE-Master-Article.aspx`

**Screenshot:**
```
[Completed template page showing all sections]
```

### 6.5 Create Quick Reference Template

1. **Create another page:**
   - **+ New** → **Site Page**
   - Layout: **Article**

2. **Title:** `TEMPLATE - Quick Reference`

3. **Add Quick Reference Table:**
   - One column section
   - Text web part
   - Type:
   ```
   ## Quick Reference
   
   | Item | Description | Notes |
   |------|-------------|-------|
   | Item 1 | Description | Notes |
   | Item 2 | Description | Notes |
   | Item 3 | Description | Notes |
   ```

4. **Add Checklist:**
   - Text web part
   - Type:
   ```
   ## Checklist
   
   - ☐ Task 1
   - ☐ Task 2
   - ☐ Task 3
   ```

5. **Save as draft**

✅ **Step 6 Complete!** Page templates are created.

---

## Step 7: Design Home Page

**Time:** 20 minutes

### 7.1 Edit Existing Home Page

1. Navigate to site home: `https://[yourtenant].sharepoint.com/sites/kb`

2. Click **Edit** button (top right)

### 7.2 Add Hero Web Part

1. **Edit hero section** (if not already there):
   - Click **Edit web part** (pencil icon on hero)
   - OR add new: Click **+** → Search "Hero" → Add

2. **Configure hero:**
   - **Layout:** Tiles or Layers (your choice)
   - Click **+ Add layer**
   
   **Layer 1:**
   - Click **Change** to upload image or select from stock
   - **Heading:** `Welcome to the IT Knowledge Base`
   - **Call to action:**
     - Label: `Get Started`
     - Link: `/sites/kb/SitePages` (or to a getting started article)

### 7.3 Add Quick Links

1. **Add new section:**
   - Click **+** between sections
   - Select **One column**

2. **Add Quick Links web part:**
   - Click **+** in section
   - Search: `Quick Links`
   - Select **Quick Links**

3. **Add links:**
   - Click **+ New link**
   
   **Link 1:**
   - Title: `Browse All Articles`
   - URL: `https://[yourtenant].sharepoint.com/sites/kb/SitePages`
   
   **Link 2:**
   - Title: `M365 Guides`
   - URL: `/sites/kb/SitePages` (filter M365 category)
   
   **Link 3:**
   - Title: `Security & Compliance`
   - URL: `/sites/kb/SitePages`
   
   **Link 4:**
   - Title: `Contact KB Admin`
   - URL: `mailto:kb.admin@company.com`

4. **Layout:** Select **Compact** or **List**

### 7.4 Add News Web Part (Optional)

1. Add another section
2. Add **News** web part
3. Configure to show latest articles

### 7.5 Publish Home Page

1. Click **Publish** (top right)
2. Click **Promote** if you want additional visibility

### 7.6 Set as Homepage

1. Click **...** (top right)
2. **Make homepage** (if not already)

**Screenshot:**
```
[Completed home page with Hero, Quick Links, and News]
```

✅ **Step 7 Complete!** Home page designed and published.

---

## Step 8: Upload Site Logo

**Time:** 5 minutes

### 8.1 Prepare Logo

- Format: PNG or SVG
- Recommended size: 192 x 192 pixels
- Transparent background preferred
- File name: `kb-logo.png`

### 8.2 Upload to Site Assets

1. **Go to Site Assets:**
   - Click **Settings gear ⚙️** → **Site contents**
   - Click **Site Assets**

2. **Create Images folder:**
   - Click **+ New** → **Folder**
   - Name: `Images`
   - Click **Create**

3. **Upload logo:**
   - Open **Images** folder
   - Click **Upload** → **Files**
   - Select your `kb-logo.png`
   - Click **Open**

### 8.3 Apply Logo to Site

1. **Open site settings:**
   - Click **Settings gear ⚙️**
   - Click **Change the look**

2. **Select Header:**
   - Click **Header** section

3. **Add logo:**
   - Under Logo, click **+ Add logo**
   - Navigate: **Site Assets** → **Images**
   - Click `kb-logo.png`
   - Click **Open**

4. **Adjust if needed:**
   - Reposition logo
   - Adjust size

5. Click **Save**

6. **Verify:**
   - Logo appears in top left of site

**Screenshot:**
```
[Site header showing custom logo]
```

✅ **Step 8 Complete!** Site logo uploaded and applied.

---

## Step 9: Integrate with Microsoft Teams

**Time:** 10 minutes

### 9.1 Open Microsoft Teams

1. Open Teams (desktop app or web browser)
2. Sign in if needed

### 9.2 Choose Team and Channel

1. **Select your Team:**
   - Choose existing team (e.g., "IT Department")
   - OR create new team for KB if needed

2. **Select or create channel:**
   - Use existing (e.g., "General")
   - OR create "Knowledge Base" channel

### 9.3 Add SharePoint Tab

1. **Add tab:**
   - Click **+** at top of channel (next to existing tabs)

**Screenshot:**
```
[Teams channel header showing + button to add tabs]
```

2. **Select SharePoint:**
   - Search for: `SharePoint`
   - Click **SharePoint** app tile

3. **Select site:**
   - You'll see recent SharePoint sites
   - Find and click: **IT Knowledge Base**
   - OR click **Add page from any SharePoint site**
   - Paste: `https://[yourtenant].sharepoint.com/sites/kb`

4. **Configure tab:**
   - **Tab name:** `Knowledge Base`
   - Check: ☑ **Post to the channel about this tab**
   - Click **Save**

### 9.4 Verify Integration

1. New **Knowledge Base** tab appears in channel
2. Click the tab
3. Your KB site loads within Teams
4. Users can browse without leaving Teams

**Screenshot:**
```
[Microsoft Teams showing Knowledge Base tab with embedded SharePoint site]
```

### 9.5 Pin Tab (Optional)

1. Right-click **Knowledge Base** tab
2. Select **Pin**
3. Tab stays visible when switching channels

✅ **Step 9 Complete!** Teams integration configured.

---

## Step 10: Create First Article

**Time:** 15 minutes

### 10.1 Navigate to Site Pages

1. Go to your KB site
2. **Site contents** → **Site Pages**

### 10.2 Copy Template

**Method 1: Copy Template Page**

1. Find **TEMPLATE - Master Article** in library
2. Click **...** (three dots) → **Copy to**
3. Select **Site Pages** (same location)
4. Click **Copy here**
5. Page is copied with name "TEMPLATE - Master Article - Copy"

**Method 2: Create New from Scratch**

1. Click **+ New** → **Site Page**
2. Choose **Article** layout

### 10.3 Rename and Edit

1. **Open the copied page** (or new page)

2. **Change title:**
   - Delete "TEMPLATE - Master Article - Copy"
   - Type: `Getting Started with the Knowledge Base`

3. **Edit Overview section:**
   - Click in the text
   - Replace with:
   ```
   The IT Knowledge Base is your central resource for technology guides, 
   process documentation, and best practices. This guide will help you 
   navigate and use the KB effectively.
   ```

4. **Update Prerequisites:**
   ```
   - Microsoft 365 account
   - Access to SharePoint site
   - Web browser (Chrome, Edge, or Firefox)
   ```

5. **Edit Step 1:**
   - Title: `Browse Categories`
   - Content:
   ```
   1. Navigate to the KB site
   2. Look at the left sidebar in Site Pages
   3. Click to expand categories (M365, AI, etc.)
   4. Click any subcategory to see articles
   ```

6. **Edit Step 2:**
   - Title: `Search for Articles`
   - Content:
   ```
   1. Use the search box at the top of the page
   2. Type keywords related to your topic
   3. Click on search results to open articles
   4. Use filters to narrow results by category
   ```

7. **Edit Step 3:**
   - Title: `Bookmark Important Articles`
   - Content:
   ```
   1. Open an article you use frequently
   2. Click the bookmark icon in your browser
   3. Save to "KB Favorites" folder
   ```

### 10.4 Set Metadata

1. **Open page details:**
   - Click **...** (top right)
   - Select **Page details**

2. **Fill in fields:**
   - **Article Summary:** 
     ```
     Learn how to navigate, search, and use the IT Knowledge Base effectively
     ```
   
   - **Knowledge Category:**
     - Click in the field
     - Navigate: **M365** → **SharePoint**
     - Click **SharePoint**
   
   - **Last Review Date:** Today's date

3. Click **Save and close**

### 10.5 Publish Article

1. Click **Publish** (top right)
2. Article is now live!

### 10.6 Verify Article

1. **Check in Site Pages:**
   - Go to Site Pages library
   - Your article appears in the list

2. **Check in Navigation:**
   - Look at left sidebar
   - Expand **M365** → **SharePoint**
   - Your article should appear

**Screenshot:**
```
[Site Pages library showing article with metadata navigation]
```

✅ **Step 10 Complete!** First article created and published.

---

## Step 11: Add Users

**Time:** 10 minutes

### 11.1 Add Users to KB Visitors (All Users)

1. **Navigate to permissions:**
   - **Settings gear ⚙️** → **Site permissions**

2. **Open KB Visitors group:**
   - Click **KB Visitors**

3. **Add members:**
   - Click **New** → **Add Users to this group**
   
4. **Add all employees:**
   - Type: `Everyone except external users`
   - This gives all internal staff read access
   - Click **Share**

**OR add specific groups:**
   - Type Azure AD group: `All-Company@yourcompany.com`
   - Click **Share**

### 11.2 Add Content Contributors

1. **Open KB Members:**
   - Go back to permissions page
   - Click **KB Members**

2. **Add contributors:**
   - Click **New** → **Add Users**
   - Add individuals:
     - `john.doe@company.com`
     - `jane.smith@company.com`
   - OR add groups:
     - `IT-Staff@company.com`
     - `Content-Contributors@company.com`
   - Click **Share**

### 11.3 Add Administrators

1. **Open KB Owners:**
   - Click **KB Owners**

2. **Add admins:**
   - Click **New** → **Add Users**
   - Add:
     - `kb.admin@company.com`
     - `sharepoint.admin@company.com`
   - Click **Share**

### 11.4 Send Welcome Email

**Sample email:**

```
Subject: New IT Knowledge Base Now Available!

Hi Team,

Our new IT Knowledge Base is now live!

🔗 Access here: https://[yourtenant].sharepoint.com/sites/kb
📱 Teams: Go to [Team Name] > Knowledge Base tab

What you'll find:
• Technology guides and how-tos
• Process documentation
• Best practices and tips
• Troubleshooting guides

Browse by category or use search to find what you need.

Questions? Contact: kb.admin@company.com

Thanks,
IT Team
```

✅ **Step 11 Complete!** Users added and notified.

---

## 🎉 Deployment Complete!

### What You've Accomplished

✅ **Site Setup:**
- Created Communication Site
- Configured branding and logo
- Designed home page

✅ **Taxonomy & Metadata:**
- Created term store structure (4 categories, 13 subcategories)
- Added custom columns to Site Pages
- Enabled metadata navigation

✅ **Security:**
- Created 3 security groups
- Configured permissions (Read, Edit, Full Control)
- Added users

✅ **Content:**
- Created page templates
- Published first article
- Set up navigation

✅ **Integration:**
- Added to Microsoft Teams
- Enabled for all users

---

## Next Steps

### Week 1
1. ✏️ Create 5-10 high-priority articles
2. 👥 Train content contributors
3. 📣 Announce to wider organization

### Week 2-4
4. 📊 Monitor usage and gather feedback
5. 🏷️ Add more categories if needed
6. 📝 Expand content library
7. 📈 Review analytics

### Ongoing
8. 🔄 Regular content reviews (quarterly)
9. 👤 Onboard new contributors
10. 📊 Generate monthly reports
11. ✨ Continuous improvement

---

## 📚 Additional Resources

**Creating Content:**
- Use templates for consistency
- Include screenshots
- Tag with appropriate categories
- Write clear, concise instructions

**Managing Taxonomy:**
- Add new terms: SharePoint Admin Center → Term Store
- Keep structure 2-3 levels deep
- Use clear, descriptive names
- Don't create too many categories

**User Training:**
- Share getting started article
- Host Q&A sessions
- Create video tutorials
- Provide quick reference guides

---

## 🆘 Troubleshooting

| Issue | Solution |
|-------|----------|
| Can't create site | Verify SharePoint Admin role |
| Taxonomy not showing | Wait 10 minutes for propagation |
| Navigation tree missing | Check metadata navigation settings |
| Users can't access | Check group membership and permissions |
| Templates not working | Save as draft, not published |

---

## 📝 Quick Reference

**Your Site URL:**
```
https://[yourtenant].sharepoint.com/sites/kb
```

**Admin Resources:**
- SharePoint Admin Center: `https://[yourtenant]-admin.sharepoint.com`
- Term Store: Admin Center → Content services → Term store
- Site Permissions: Settings gear → Site permissions
- Library Settings: Site Pages → Settings → Library settings

**Security Groups:**
- KB Visitors: Read-only access
- KB Members: Can create/edit articles
- KB Owners: Full administration

---

**✅ Your Knowledge Base is ready to use!**

**Version:** 1.0  
**Created:** 2026-01-09  
**Author:** Jyotirmoy Bhowmik  
**Deployment Method:** Manual (Browser Only)

# SharePoint Online Knowledge Base - Detailed Step-by-Step Deployment Guide

## 📋 Table of Contents

1. [Pre-Deployment Preparation](#pre-deployment-preparation)
2. [Environment Setup](#environment-setup)
3. [Configuration Customization](#configuration-customization)
4. [Deployment Execution](#deployment-execution)
5. [Post-Deployment Configuration](#post-deployment-configuration)
6. [Validation & Testing](#validation--testing)
7. [First Content Creation](#first-content-creation)
8. [Teams Integration](#teams-integration)
9. [User Onboarding](#user-onboarding)

---

## Pre-Deployment Preparation

### Step 1: Verify Your Microsoft 365 Environment

**Time Required:** 10 minutes

#### 1.1 Check Your SharePoint Online License

1. Open your web browser
2. Navigate to `https://admin.microsoft.com`
3. Sign in with your Microsoft 365 administrator account
4. In the left navigation, click **Billing** → **Licenses**
5. Verify you have **SharePoint Online (Plan 1 or Plan 2)** licenses available
6. Note: Microsoft 365 Business Premium, E3, or E5 include SharePoint Online

**Expected Result:** You should see active SharePoint licenses

**Troubleshooting:**
- If no licenses shown, contact your Microsoft account manager
- If licenses expired, renew subscription before proceeding

#### 1.2 Verify Administrator Permissions

1. Still in Microsoft 365 Admin Center (`admin.microsoft.com`)
2. Click **Users** → **Active users**
3. Search for your account name
4. Click on your name to open details
5. Click **Roles** tab
6. Verify you have one of these roles:
   - ✅ Global Administrator
   - ✅ SharePoint Administrator
   - ⚠️ **Minimum Required:** SharePoint Administrator

**Screenshot Guide:**
```
[Screenshot: Microsoft 365 Admin Center showing user roles with SharePoint Administrator checked]
```

**If you don't have permissions:**
1. Ask your Global Administrator to assign SharePoint Administrator role
2. Instructions for Global Admin:
   - Click **Edit** next to Roles
   - Select **SharePoint Administrator**
   - Click **Save changes**
3. Sign out and back in for permissions to take effect

#### 1.3 Verify Term Store Access

1. Navigate to SharePoint Admin Center: `https://[yourtenant]-admin.sharepoint.com`
   - Replace `[yourtenant]` with your actual tenant name
   - Example: `https://contoso-admin.sharepoint.com`
2. In left navigation, click **Content services**
3. Click **Term store**
4. You should see the term store interface load

**Expected Result:** Term store loads without "Access Denied" error

**If Access Denied:**
1. Go back to SharePoint Admin Center homepage
2. Click **More features** in left navigation
3. Under **Term store**, click **Open**
4. In the new window, click **Term Store Administrators** in the ribbon
5. Add your account as Term Store Administrator
6. Wait 5 minutes for permissions to propagate

---

## Environment Setup

### Step 2: Install Required Software

**Time Required:** 15 minutes

#### 2.1 Install PowerShell 7 (Recommended) or Verify PowerShell 5.1

**Option A: Install PowerShell 7 (Recommended)**

1. Open your current PowerShell
   - Press `Windows Key + X`
   - Select **Windows PowerShell** or **Terminal**

2. Check current version:
   ```powershell
   $PSVersionTable.PSVersion
   ```

3. If version is below 7.0, download and install:
   - Go to: https://github.com/PowerShell/PowerShell/releases/latest
   - Download `PowerShell-7.x.x-win-x64.msi`
   - Run the installer
   - Select **Add PowerShell to PATH** during installation
   - Click **Install**

4. After installation, close all PowerShell windows

5. Open **PowerShell 7**:
   - Press `Windows Key`
   - Type "PowerShell 7"
   - Right-click → **Run as Administrator**

**Expected Result:**
```
PowerShell 7.x.x
```

**Option B: Use Existing PowerShell 5.1**

1. Open PowerShell as Administrator:
   - Press `Windows Key + X`
   - Select **Windows PowerShell (Admin)**

2. Verify version:
   ```powershell
   $PSVersionTable.PSVersion
   ```

**Expected Output:**
```
Major  Minor  Build  Revision
-----  -----  -----  --------
5      1      xxxxx  xxxx
```

3. If version is 5.1 or higher, you're good to proceed

#### 2.2 Install PnP PowerShell Module

**CRITICAL:** This is the most important module for deployment

1. In PowerShell (running as Administrator), run:
   ```powershell
   Install-Module -Name PnP.PowerShell -Force -AllowClobber -Scope CurrentUser
   ```

2. When prompted about NuGet provider, type `Y` and press Enter

3. When prompted about untrusted repository, type `Y` and press Enter

4. Wait for installation to complete (may take 2-3 minutes)

**Expected Output:**
```
Installing package 'PnP.PowerShell'
...
Installed module
```

5. Verify installation:
   ```powershell
   Get-Module -Name PnP.PowerShell -ListAvailable
   ```

**Expected Output:**
```
ModuleType Version    Name              PSEdition ExportedCommands
---------- -------    ----              --------- ----------------
Script     2.x.x      PnP.PowerShell    Desk      {Add-PnPAlert, Add-PnPApp...
```

**Troubleshooting:**

**Error: "Install-Module is not recognized"**
- Install PowerShellGet:
  ```powershell
  Install-PackageProvider -Name NuGet -Force
  Install-Module -Name PowerShellGet -Force
  ```
- Close and reopen PowerShell
- Retry PnP.PowerShell installation

**Error: "Execution policy"**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### 2.3 Test SharePoint Connection

1. Test connection to your tenant:
   ```powershell
   Connect-PnPOnline -Url "https://[yourtenant]-admin.sharepoint.com" -Interactive
   ```
   Replace `[yourtenant]` with your actual tenant name

2. A browser window will open

3. Sign in with your SharePoint Administrator account

4. If prompted for consent, click **Accept**

5. Return to PowerShell

**Expected Result:**
```
Connected to https://[yourtenant]-admin.sharepoint.com
```

6. Test a command:
   ```powershell
   Get-PnPTenantSite | Select-Object -First 3 Url
   ```

**Expected Output:**
```
Url
---
https://yourtenant.sharepoint.com
https://yourtenant.sharepoint.com/sites/sitename1
https://yourtenant.sharepoint.com/sites/sitename2
```

7. Disconnect:
   ```powershell
   Disconnect-PnPOnline
   ```

**If connection fails:**
- Verify you're using correct tenant name
- Check if multi-factor authentication is enabled (it's supported)
- Ensure no VPN or proxy blocking connection
- Try connecting to regular site instead of admin:
  ```powershell
  Connect-PnPOnline -Url "https://[yourtenant].sharepoint.com" -Interactive
  ```

---

## Configuration Customization

### Step 3: Download and Prepare Project Files

**Time Required:** 10 minutes

#### 3.1 Locate Project Files

1. Open File Explorer
2. Navigate to: `C:\Users\[YourUsername]\KnowledgePortal`
   - Or wherever you extracted/cloned the project

3. Verify folder structure:
   ```
   KnowledgePortal/
   ├── scripts/
   ├── config/
   ├── docs/
   ├── admin-portal/
   └── README.md
   ```

**If files are missing:**
- Ensure you copied all files from the project repository
- Check if files were blocked by antivirus
- Re-download if necessary

#### 3.2 Customize Taxonomy Configuration

**File:** `config/taxonomy.json`

1. Navigate to `KnowledgePortal\config\`
2. Right-click `taxonomy.json` → **Open with** → **Notepad** (or VS Code/Notepad++)

3. Review the structure:
   ```json
   {
     "termGroup": {
       "name": "Enterprise Knowledge",
       "description": "..."
     },
     "terms": [
       {
         "name": "M365",
         "children": [...]
       }
     ]
   }
   ```

4. **Customize for your organization:**
   
   **Example: Add SAP category**
   
   Find the `"terms"` array and add:
   ```json
   {
     "name": "SAP",
     "id": "00000000-0000-0000-0000-000000000005",
     "description": "SAP ERP System",
     "children": [
       {
         "name": "Finance",
         "id": "00000000-0000-0000-0000-000000000051",
         "description": "SAP Finance (FI) module"
       },
       {
         "name": "Materials Management",
         "id": "00000000-0000-0000-0000-000000000052",
         "description": "SAP MM module"
       }
     ]
   }
   ```

5. **IMPORTANT:** Keep valid JSON structure
   - Add comma after previous term
   - Don't forget closing braces
   - Use a JSON validator if unsure: https://jsonlint.com/

6. Save the file (Ctrl + S)

**Validation:**
```powershell
# Test JSON is valid
$json = Get-Content "C:\path\to\config\taxonomy.json" -Raw | ConvertFrom-Json
Write-Host "JSON is valid!" -ForegroundColor Green
```

#### 3.3 Customize Site Configuration

**File:** `config/site-config.json`

1. Open `config\site-config.json`

2. **REQUIRED CHANGES:**

   **Change the owner email:**
   ```json
   {
     "site": {
       "owner": "YOUR.EMAIL@yourcompany.com",  // ⬅️ CHANGE THIS
       ...
     }
   }
   ```

   **Customize the site URL alias:**
   ```json
   {
     "site": {
       "urlAlias": "kb",  // ⬅️ Change to your preference (e.g., "knowledgebase", "wiki")
       ...
     }
   }
   ```
   **Note:** This creates: `https://yourtenant.sharepoint.com/sites/kb`

   **Set your time zone:**
   ```json
   {
     "site": {
       "timeZone": 13,  // ⬅️ Your timezone ID
       ...
     }
   }
   ```

   **Common Time Zones:**
   - `2` - (GMT-08:00) Pacific Time (US & Canada)
   - `10` - (GMT-06:00) Central Time (US & Canada)
   - `13` - (GMT-05:00) Eastern Time (US & Canada)
   - `15` - (GMT) Greenwich Mean Time
   - `31` - (GMT+01:00) Amsterdam, Berlin, Rome, Vienna
   - `37` - (GMT+05:30) Chennai, Kolkata, Mumbai, New Delhi
   - Full list: https://learn.microsoft.com/en-us/previous-versions/office/sharepoint-csom/jj171978(v=office.15)

3. **Optional: Customize branding:**
   ```json
   {
     "branding": {
       "theme": {
         "name": "Blue",  // Options: Blue, Orange, Red, Purple, Green, Gray, Teal
         ...
       }
     }
   }
   ```

4. Save the file

#### 3.4 Customize Permissions Configuration

**File:** `config/permissions.json`

1. Open `config\permissions.json`

2. **CRITICAL: Update Azure AD Group Names**

   Find each group's `azureADGroups` array and replace with YOUR actual groups:

   ```json
   {
     "name": "KB Members",
     "members": {
       "azureADGroups": [
         "IT-Staff@yourcompany.com",  // ⬅️ Replace with your actual AD group
         "Knowledge-Contributors@yourcompany.com"  // ⬅️ Add your groups
       ],
       "users": [
         "specificuser@yourcompany.com"  // ⬅️ Or add individual users
       ]
     }
   }
   ```

3. **How to find your Azure AD group names:**
   
   **Method 1: Azure AD Portal**
   - Go to: https://portal.azure.com
   - Navigate to **Azure Active Directory** → **Groups**
   - Find your group
   - Copy the **Mail** or **Object ID**

   **Method 2: PowerShell**
   ```powershell
   Connect-AzureAD
   Get-AzureADGroup -SearchString "IT" | Select-Object DisplayName, Mail
   ```

4. **If you don't have Azure AD groups:**
   - Remove the `azureADGroups` entries
   - Add individual users to the `users` array
   - Or leave empty and configure manually later

5. Save the file

---

## Deployment Execution

### Step 4: Run the Master Deployment Script

**Time Required:** 15-20 minutes

#### 4.1 Open PowerShell and Navigate to Scripts Folder

1. **Open PowerShell 7 as Administrator:**
   - Press `Windows Key`
   - Type "PowerShell 7"
   - Right-click → **Run as Administrator**
   - Click **Yes** on UAC prompt

2. **Navigate to the scripts folder:**
   ```powershell
   cd "C:\Users\YourUsername\KnowledgePortal\scripts"
   ```
   
   Replace `YourUsername` with your actual Windows username

3. **Verify you're in the correct location:**
   ```powershell
   Get-ChildItem *.ps1
   ```

   **Expected Output:**
   ```
   01-Configure-TermStore.ps1
   02-Create-CommunicationSite.ps1
   03-Setup-Metadata.ps1
   04-Configure-Permissions.ps1
   05-Setup-Navigation.ps1
   06-Deploy-Templates.ps1
   Deploy-KnowledgeBase.ps1
   New-KBArticle.ps1
   Import-BulkContent.ps1
   Test-KBDeployment.ps1
   Remove-KBDeployment.ps1
   ```

#### 4.2 Determine Your Tenant URL

Your tenant URL format is:
```
https://[TENANTNAME]-admin.sharepoint.com
```

**How to find your tenant name:**

**Method 1: Check existing SharePoint site**
- Go to any SharePoint site in your organization
- Look at the URL: `https://TENANTNAME.sharepoint.com/...`
- Your tenant name is the part before `.sharepoint.com`

**Method 2: Microsoft 365 Admin Center**
- Go to https://admin.microsoft.com
- Look at the URL bar or Settings → Domains
- Your default domain is `TENANTNAME.onmicrosoft.com`

**Example:**
- If your domain is `contoso.onmicrosoft.com`
- Your tenant URL is: `https://contoso-admin.sharepoint.com`


#### 4.3 Run Dry-Run Test (WhatIf Mode)

**HIGHLY RECOMMENDED** - This previews what will happen without making changes

```powershell
.\Deploy-KnowledgeBase.ps1 `
    -TenantUrl "https://YOURTENANTNAME-admin.sharepoint.com" `
    -WhatIf `
    -Verbose
```

**Replace YOURTENANTNAME** with your actual tenant name!

**What happens:**
1. Script checks prerequisites
2. Validates configuration files
3. Shows what WOULD be created (but doesn't create it)
4. Reports any issues

**Expected Output:**
```
[timestamp] [Info] ========================================
[timestamp] [Info] SharePoint Knowledge Base Deployment v1.0.0
[timestamp] [Info] ========================================
[timestamp] [Info] Running in WHATIF mode - no changes will be made
[timestamp] [Info] Checking prerequisites...
[timestamp] [Success] PnP.PowerShell version: 2.x.x
[timestamp] [Success] All configuration files found
[timestamp] [Success] All deployment scripts found
[timestamp] [Success] Prerequisites check passed!
[timestamp] [Info] Target Site URL: https://YOURTENANTNAME.sharepoint.com/sites/kb
...
[timestamp] [Info] [WhatIf] Would create term group: Enterprise Knowledge
[timestamp] [Info] [WhatIf] Would create Communication Site
...
```

**If errors appear:**
- Missing config files → Verify config folder exists
- Module not found → Re-run Step 2.2
- Invalid JSON → Validate JSON files with jsonlint.com

#### 4.4 Run Actual Deployment

**⚠️ WARNING:** This will create real resources in SharePoint Online

```powershell
.\Deploy-KnowledgeBase.ps1 `
    -TenantUrl "https://YOURTENANTNAME-admin.sharepoint.com" `
    -Verbose
```

**Step-by-Step Execution:**

**Minute 0-2: Prerequisites & Connection**
```
[timestamp] [Info] Checking prerequisites...
```
- You'll see a browser window open
- Sign in with your SharePoint Admin account
- Complete MFA if required
- Return to PowerShell

**Minute 2-5: Step 1 - Configure Term Store**
```
[timestamp] [Info] Step 1: Configure Term Store Taxonomy
[timestamp] [Info] Connecting to SharePoint Online: https://...
[timestamp] [Success] Connected successfully
[timestamp] [Info] Looking for term group: Enterprise Knowledge
[timestamp] [Info] Term group not found. Creating new term group...
[timestamp] [Success] Created term group: Enterprise Knowledge
[timestamp] [Success] Created term set: KB Structure
[timestamp] [Info] Creating terms hierarchy...
[timestamp] [Success] Created root term: M365
[timestamp] [Success]   Created child term: Teams under M365
[timestamp] [Success]   Created child term: OneDrive under M365
...
[timestamp] [Success] Step 1 completed successfully in X seconds
```

**What's happening:** Creating taxonomy structure in Term Store

**Minute 5-8: Step 2 - Create Communication Site**
```
[timestamp] [Info] Step 2: Create Communication Site
[timestamp] [Info] Site URL will be: https://TENANTNAME.sharepoint.com/sites/kb
[timestamp] [Info] Creating Communication Site...
[timestamp] [Success] Communication Site created successfully!
[timestamp] [Info] Applying branding configurations...
[timestamp] [Success] Step 2 completed successfully in X seconds
```

**What's happening:** Provisioning new SharePoint site

**Minute 8-11: Step 3 - Setup Metadata**
```
[timestamp] [Info] Step 3: Setup Metadata Columns
[timestamp] [Info] Creating KnowledgeCategory column...
[timestamp] [Success] Created KnowledgeCategory column linked to term set
[timestamp] [Success] Created ArticleSummary column
[timestamp] [Success] Created LastReviewDate column with default value = today
[timestamp] [Success] Created Knowledge Cards view
[timestamp] [Success] Enabled versioning (10 major, 5 minor versions)
[timestamp] [Success] Step 3 completed successfully in X seconds
```

**What's happening:** Adding custom columns to Site Pages library

**Minute 11-14: Step 4 - Configure Permissions**
```
[timestamp] [Info] Step 4: Configure Permissions
[timestamp] [Info] Breaking permission inheritance...
[timestamp] [Success] Permission inheritance broken
[timestamp] [Info] Processing group: KB Visitors
[timestamp] [Success] Created group: KB Visitors
[timestamp] [Success] Assigned Read permission to KB Visitors
[timestamp] [Success] Added Everyone to KB Visitors
...
[timestamp] [Success] Step 4 completed successfully in X seconds
```

**What's happening:** Creating security groups and assigning permissions

**Minute 14-16: Step 5 - Setup Navigation**
```
[timestamp] [Info] Step 5: Setup Navigation
[timestamp] [Success] Added 'Knowledge Base' link to Quick Launch
[timestamp] [Success] Navigation links configured
[timestamp] [Info] Note: Metadata navigation requires manual configuration
[timestamp] [Success] Step 5 completed successfully in X seconds
```

**What's happening:** Configuring site navigation

**Minute 16-18: Step 6 - Deploy Templates**
```
[timestamp] [Info] Step 6: Deploy Page Templates
[timestamp] [Info] Creating template: Master Article Template
[timestamp] [Success] Created page: template-master-article.aspx
[timestamp] [Success] Template 'Master Article Template' created successfully
...
[timestamp] [Success] Step 6 completed successfully in X seconds
```

**What's happening:** Creating reusable page templates

**Minute 18-20: Deployment Summary**
```
[timestamp] [Info] ========================================
[timestamp] [Info] DEPLOYMENT SUMMARY
[timestamp] [Info] ========================================
[timestamp] [Info] Total Duration: X.X minutes
[timestamp] [Info] Steps Completed: 6 / 6
[timestamp] [Success]   Step 1: SUCCESS
[timestamp] [Success]   Step 2: SUCCESS
[timestamp] [Success]   Step 3: SUCCESS
[timestamp] [Success]   Step 4: SUCCESS
[timestamp] [Success]   Step 5: SUCCESS
[timestamp] [Success]   Step 6: SUCCESS
[timestamp] [Success] Site URL: https://TENANTNAME.sharepoint.com/sites/kb
[timestamp] [Info] Log File: ../logs/Deploy-KB-TIMESTAMP.log

[timestamp] [Info] ========================================
[timestamp] [Success] DEPLOYMENT COMPLETED SUCCESSFULLY!
[timestamp] [Info] ========================================
```

**🎉 SUCCESS! Your Knowledge Base is deployed!**

#### 4.5 Review Log Files

1. Navigate to logs folder:
   ```powershell
   cd ..\logs
   dir
   ```

2. Open the latest deployment log:
   ```powershell
   notepad Deploy-KB-*.log
   ```

3. **What to look for:**
   - All steps show `[Success]`
   - No `[Error]` entries
   - Final status: "DEPLOYMENT COMPLETED SUCCESSFULLY"

4. **If errors found:**
   - Note the step number that failed
   - Refer to troubleshooting section in deployment-runbook.md
   - Re-run individual script if needed

---

## Post-Deployment Configuration

### Step 5: Manual Metadata Navigation Setup

**Time Required:** 5 minutes

**⚠️ CRITICAL STEP** - This must be done manually in SharePoint UI

#### 5.1 Configure Metadata Navigation

1. **Open your Knowledge Base site:**
   - Open browser
   - Navigate to: `https://YOURTENANTNAME.sharepoint.com/sites/kb`
   - Sign in if prompted

2. **Navigate to Site Pages library:**
   - Click **Site contents** in left navigation (gear icon → Site contents)
   - Click **Site Pages**

3. **Access Library Settings:**
   - Click the **Settings gear ⚙️** (top right)
   - Click **Library settings**

   **Screenshot Guide:**
   ```
   [Screenshot: Library ribbon with Settings gear highlighted]
   ```

4. **Open Metadata Navigation Settings:**
   - Scroll down to **General Settings** section
   - Click **Metadata navigation settings**

   **Screenshot Guide:**
   ```
   [Screenshot: General Settings section with "Metadata navigation settings" link highlighted]
   ```

5. **Configure Navigation Hierarchies:**
   
   You'll see two panes:
   - **Available Hierarchy Fields** (left)
   - **Selected Hierarchy Fields** (right)

   **Steps:**
   - In the left pane, find **Knowledge Category**
   - Click on **Knowledge Category**
   - Click the **Add >>** button to move it to the right pane

   **Screenshot Guide:**
   ```
   [Screenshot: Metadata navigation configuration screen with Knowledge Category being moved]
   ```

6. **Configure Key Filters (Optional but Recommended):**
   
   Below the hierarchies, you'll see:
   - **Available Key Filter Fields** (left)
   - **Selected Key Filter Fields** (right)

   **Recommended filters to add:**
   - **Modified** (helps filter by date)
   - **Last Review Date**
   - **Author**

   For each:
   - Click the field name
   - Click **Add >>**

7. **Save Configuration:**
   - Click **OK** at the bottom of the page
   - Wait for page to refresh (may take 5-10 seconds)

8. **Verify Navigation Tree:**
   - Go back to **Site Pages** library
   - Look at the left side of the library view
   - You should now see **Knowledge Category** with expandable tree

   **Screenshot Guide:**
   ```
   [Screenshot: Site Pages library showing metadata navigation tree on left with M365, AI, Development, Security categories]
   ```

   **Expected Tree Structure:**
   ```
   ▼ Knowledge Category
     ▶ M365
     ▶ AI
     ▶ Development
     ▶ Security
   ```

   **Note:** Categories appear empty until you create articles

**Troubleshooting:**

**Tree doesn't appear:**
- Refresh page (Ctrl + F5)
- Clear browser cache
- Verify Knowledge Category field exists (Library Settings → Columns)
- Wait 5 minutes and try again

**"Knowledge Category" not in available fields:**
- The column wasn't created
- Re-run script 03-Setup-Metadata.ps1

### Step 6: Create Home Page

**Time Required:** 10 minutes

#### 6.1 Create Welcome Home Page

1. **Navigate to your KB site:**
   `https://YOURTENANTNAME.sharepoint.com/sites/kb`

2. **Create new page:**
   - Click **+ New** → **Page**
   - Choose **Home** layout template
   - Click **Create page**

3. **Add Hero Web Part:**
   - The Hero web part should be added by default
   - Click **Edit web part** (pencil icon)
   - Click **+ Add layer**
   
   **Configure Layer 1:**
   - **Layout**: Tiles or Layers (your choice)
   - **Image**: Click **Change** → Upload a welcoming image
   - **Title**: "Welcome to the IT Knowledge Base"
   - **Description**: "Your central hub for IT documentation, guides, and best practices"
   - **Call to action**: "Get Started"
   - **Link**: Leave blank or link to a getting started article
   
4. **Add Quick Links Web Part:**
   - Click **+** in a new section
   - Search for "Quick Links"
   - Select **Quick Links** web part
   - Click **+ New link**
   
   **Add these links:**
   - **Link 1:**
     - Title: "All Articles"
     - Address: `/sites/kb/SitePages`
   - **Link 2:**
     - Title: "Create New Article"
     - Address: `/sites/kb/SitePages/Forms/AllItems.aspx`
   - **Link 3:**
     - Title: "M365 Guides"
     - Address: `/sites/kb/SitePages` (filter by M365 category)
   - **Link 4:**
     - Title: "Security & Compliance"
     - Address: `/sites/kb/SitePages`

5. **Add News Web Part (Optional):**
   - Click **+** in a new section
   - Search for "News"
   - Select **News** web part
   - This will show latest articles published as news

6. **Set Page Title:**
   - Click in the page title area at top
   - Type: "Home" or "Welcome to IT Knowledge Base"

7. **Publish Page:**
   - Click **Publish** (top right)
   - Click **Promote** if you want to feature this page

8. **Set as Home Page:**
   - Click **...** (top right) → **Make homepage**
   - Click **Save**

**Screenshot Guide:**
```
[Screenshot: Completed home page with Hero web part, Quick Links, and News section]
```

### Step 7: Upload Site Logo

**Time Required:** 5 minutes

1. **Prepare your logo:**
   - Format: PNG or SVG (PNG recommended)
   - Size: 192 x 192 pixels minimum
   - Transparent background works best
   - File size: < 500 KB

2. **Upload to Site Assets:**
   - Go to **Site contents**
   - Click **Site Assets**
   - Create new folder: **Images**
   - Open **Images** folder
   - Click **Upload** → **Files**
   - Select your logo file: `kb-logo.png`
   - Click **Open**

3. **Apply Logo to Site:**
   - Click **Settings gear ⚙️** (top right)
   - Click **Change the look**
   - Click **Header** section
   - Under **Logo**, click **+ Add logo**
   - Navigate to **Site Assets** → **Images**
   - Select your `kb-logo.png`
   - Adjust position if needed
   - Click **Save**

4. **Verify Logo:**
   - Logo should appear in top left of site
   - Refresh page to see changes

**Screenshot Guide:**
```
[Screenshot: Site header showing custom logo]
```

---

## Validation & Testing

### Step 8: Run Validation Script

**Time Required:** 5 minutes

#### 8.1 Execute Validation Script

1. **Return to PowerShell** (still as Administrator)

2. **Navigate to scripts folder if not there:**
   ```powershell
   cd "C:\Users\YourUsername\KnowledgePortal\scripts"
   ```

3. **Run validation:**
   ```powershell
   .\Test-KBDeployment.ps1 `
       -SiteUrl "https://YOURTENANTNAME.sharepoint.com/sites/kb" `
       -GenerateReport
   ```

4. **Review Results:**

   **Expected Output:**
   ```
   [timestamp] [Info] Testing: Site Accessibility
   [timestamp] [Success]   PASS: Site Accessibility
   [timestamp] [Info] Testing: Site Pages Library
   [timestamp] [Success]   PASS: Site Pages Library
   [timestamp] [Info] Testing: KnowledgeCategory Column
   [timestamp] [Success]   PASS: KnowledgeCategory Column
   ...
   [timestamp] [Info] ========================================
   [timestamp] [Info] Validation Summary
   [timestamp] [Info] ========================================
   [timestamp] [Info] Total Tests: 11
   [timestamp] [Success] Passed: 11
   [timestamp] [Info] Failed: 0
   [timestamp] [Success] Success Rate: 100%
   ```

5. **Open HTML Report:**
   ```powershell
   cd ..\logs
   explorer .
   ```
   - Double-click the latest `ValidationReport-*.html`
   - Opens in your browser

6. **Review HTML Report:**
   - Green checkmarks ✓ = Passed
   - Red X = Failed
   - Review any failures and address them

**If ANY tests fail:**
- Note which component failed
- Refer to troubleshooting-guide.md
- Re-run the specific deployment script
- Re-run validation

---

## First Content Creation

### Step 9: Create Your First Article

**Time Required:** 10 minutes

#### 9.1 Using PowerShell Helper (Recommended)

1. **In PowerShell:**
   ```powershell
   cd "C:\Users\YourUsername\KnowledgePortal\scripts"
   
   .\New-KBArticle.ps1 `
       -SiteUrl "https://YOURTENANTNAME.sharepoint.com/sites/kb"
   ```

2. **Interactive Prompts:**

   **Prompt 1: Article Title**
   ```
   Article Title: 
   ```
   Type: `Getting Started with the Knowledge Base`
   Press Enter

   **Prompt 2: Article Summary**
   ```
   Article Summary (brief description):
   ```
   Type: `Learn how to use and contribute to the IT Knowledge Base`
   Press Enter

   **Prompt 3: Knowledge Category**
   ```
   Available categories:
     M365/Teams - Microsoft Teams
     M365/OneDrive - OneDrive for Business
     ...
   
   Knowledge Category (e.g., 'M365/Teams'):
   ```
   Type: `M365/SharePoint`
   Press Enter

3. **Article Creation:**
   ```
   Creating article: Getting Started with the Knowledge Base
   File name: getting-started-with-the-knowledge-base.aspx
   Category: M365/SharePoint
   Template: MasterArticle
   
   Creating page from template...
   Page created successfully!
   Setting metadata...
   Metadata set successfully!
   
   ========================================
   Article Created Successfully!
   ========================================
   Title: Getting Started with the Knowledge Base
   URL: https://TENANTNAME.sharepoint.com/sites/kb/SitePages/getting-started-with-the-knowledge-base.aspx
   Status: Draft
   ========================================
   
   Open article in browser? (y/n) [y]:
   ```
   Type: `y`
   Press Enter

4. **Browser Opens:**
   - Article page opens in edit mode
   - You'll see the template structure with placeholder content

5. **Edit Article Content:**

   **Replace Overview section:**
   - Click in the "Overview" text
   - Delete placeholder text
   - Type:
     ```
     The IT Knowledge Base is your central resource for:
     - Technology guides and how-tos
     - Process documentation
     - Best practices and tips
     - Troubleshooting guides
     ```

   **Update Prerequisites:**
   - Replace with actual prerequisites if any
   - Or delete this section if not needed

   **Add Step-by-Step Instructions:**
   - Click in "Step 1" heading
   - Type: `Browse the Knowledge Base`
   - Update content:
     ```
     1. Navigate to the KB site
     2. Use the left navigation to explore categories
     3. Use search to find specific topics
     4. Click any article title to read
     ```

   **Continue for Steps 2-3:**
   - Step 2: `Search for Articles`
   - Step 3: `Contribute Content` (for contributors)

6. **Publish Article:**
   - Click **Publish** button (top right)
   - Your first article is live!

#### 9.2 Verify Article Appears

1. **Check Site Pages Library:**
   - Navigate to **Site contents** → **Site Pages**
   - Your article should appear in the list

2. **Check Metadata Navigation:**
   - In Site Pages library
   - Look at left navigation tree
   - Expand **M365** → Expand **SharePoint**
   - Your article should appear under SharePoint

3. **Verify on Home Page:**
   - Go to site home page
   - If you added News web part, article may appear there

**Screenshot Guide:**
```
[Screenshot: Site Pages library showing first article with metadata tree navigation]
```

---

## Teams Integration

### Step 10: Add Knowledge Base to Microsoft Teams

**Time Required:** 5 minutes

#### 10.1 Add as Teams Tab

1. **Open Microsoft Teams:**
   - Desktop app or browser (teams.microsoft.com)
   - Sign in if needed

2. **Navigate to Target Team/Channel:**
   - Select the Team where you want the KB
   - Select the Channel (e.g., "General" or create "Knowledge Base" channel)

3. **Add Tab:**
   - At the top of the channel, click **+ Add a tab**

   **Screenshot Guide:**
   ```
   [Screenshot: Teams channel header showing + Add a tab button]
   ```

4. **Select SharePoint:**
   - In the "Add a tab" dialog
   - Search for: `SharePoint`
   - Click the **SharePoint** tile

5. **Select Your KB Site:**
   - You'll see a list of recent SharePoint sites
   - Find and click: **IT Knowledge Base**
   - If not visible, click **Add page from any SharePoint site**
   - Paste URL: `https://YOURTENANTNAME.sharepoint.com/sites/kb`

6. **Configure Tab:**
   - **Tab name:** Type `Knowledge Base`
   - Check ✓ **Post to the channel about this tab** (optional)
   - Click **Save**

7. **Verify Tab:**
   - New **Knowledge Base** tab appears in channel header
   - Click the tab
   - Your KB site loads within Teams

**Screenshot Guide:**
```
[Screenshot: Microsoft Teams showing Knowledge Base tab with embedded SharePoint site]
```

#### 10.2 Pin Tab (Optional)

1. Right-click the **Knowledge Base** tab
2. Select **Pin tab**
3. Tab stays visible even when switching channels

#### 10.3 Add to Multiple Channels

Repeat steps 1-7 for:
- IT Support channel
- HR channel
- Finance channel
- Any department that needs KB access

---

## User Onboarding

### Step 11: Invite Users and Assign Permissions

**Time Required:** 15 minutes

#### 11.1 Add Users to KB Visitors (Read-Only)

**Option A: Via SharePoint UI**

1. **Navigate to Site Permissions:**
   - Go to your KB site
   - Click **Settings gear ⚙️** → **Site permissions**

2. **Open KB Visitors Group:**
   - Click **KB Visitors**

3. **Add Members:**
   - Click **New** → **Add Users to this group**
   - In the "Enter names or email addresses" box:
     - Type user email: `user@yourcompany.com`
     - OR type Azure AD group: `All-Employees@yourcompany.com`
   - Add a personal message (optional)
   - Click **Share**

4. **Verify Everyone Has Access:**
   - If you want ALL employees to have read access
   - Add the built-in group: `Everyone except external users`

**Option B: Via PowerShell** (Faster for bulk)

```powershell
Connect-PnPOnline -Url "https://YOURTENANTNAME.sharepoint.com/sites/kb" -Interactive

# Add individual user
Add-PnPGroupMember -LoginName "user@yourcompany.com" -Identity "KB Visitors"

# Add Azure AD group
Add-PnPGroupMember -LoginName "All-Employees@yourcompany.com" -Identity "KB Visitors"

# Verify members
Get-PnPGroupMembers -Identity "KB Visitors"
```

#### 11.2 Add Contributors to KB Members

1. **Identify Contributors:**
   - IT staff
   - Subject matter experts
   - Department representatives

2. **Add via UI:**
   - **Settings gear ⚙️** → **Site permissions**
   - Click **KB Members**
   - Click **New** → **Add Users**
   - Add each contributor

3. **Or via PowerShell:**
   ```powershell
   # Add contributors
   Add-PnPGroupMember -LoginName "it.staff@company.com" -Identity "KB Members"
   Add-PnPGroupMember -LoginName "john.doe@company.com" -Identity "KB Members"
   ```

#### 11.3 Add Administrators to KB Owners

```powershell
Add-PnPGroupMember -LoginName "kb.admin@company.com" -Identity "KB Owners"
Add-PnPGroupMember -LoginName "sharepoint.admin@company.com" -Identity "KB Owners"
```

#### 11.4 Send Welcome Email

**Sample Email Template:**

```
Subject: Welcome to the IT Knowledge Base!

Hi Team,

We're excited to announce the launch of our new IT Knowledge Base!

🔗 Access the KB: https://YOURTENANTNAME.sharepoint.com/sites/kb

What is it?
The Knowledge Base is your central hub for IT documentation, guides, and best practices.

How to use it:
• Browse categories in the left navigation
• Use the search bar to find specific topics
• Bookmark articles you use frequently
• Access via our Teams channel: [Team Name] > Knowledge Base tab

Need Help?
• Getting Started Guide: [Link to your first article]
• Contact: kb.admin@yourcompany.com

Happy exploring!
IT Team
```

---

## 🎉 Deployment Complete!

### Summary of What You've Accomplished

✅ **Environment Setup:**
- Installed PowerShell and PnP module
- Verified SharePoint permissions
- Tested connectivity

✅ **Configuration:**
- Customized taxonomy for your organization
- Configured site settings
- Set up security groups

✅ **Deployment:**
- Created Term Store structure
- Provisioned Communication Site
- Configured metadata and navigation
- Set up permissions
- Deployed page templates

✅ **Post-Configuration:**
- Configured metadata navigation
- Created home page
- Uploaded site logo
- Validated deployment

✅ **Content & Integration:**
- Created first article
- Integrated with Microsoft Teams
- Onboarded users

### Next Steps

**Week 1:**
1. Create 5-10 high-priority articles
2. Train content contributors
3. Announce to organization

**Week 2-4:**
4. Gather feedback from pilot users
5. Expand taxonomy if needed
6. Create additional articles
7. Monitor usage analytics

**Ongoing:**
8. Regular content reviews (quarterly)
9. Add new categories as needed
10. Generate monthly usage reports
11. Continuous improvement

### Support Resources

- **Documentation:** `KnowledgePortal\docs\`
- **Admin Guide:** For daily operations
- **Contributor Guide:** For content creators
- **Troubleshooting Guide:** For issues

### Need Help?

If you encounter issues:
1. Check `troubleshooting-guide.md`
2. Review log files in `logs\` folder
3. Re-run specific scripts if needed
4. Consult Microsoft SharePoint documentation

---

**🚀 Your Knowledge Base is now live and ready to use!**

**Version:** 1.0  
**Last Updated:** 2026-01-09  
**Author:** Jyotirmoy Bhowmik

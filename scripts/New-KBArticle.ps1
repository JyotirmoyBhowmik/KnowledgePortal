<#
.SYNOPSIS
    Helper script to create new Knowledge Base articles

.DESCRIPTION
    Interactive script to create new KB articles from templates with automatic metadata tagging.

.PARAMETER SiteUrl
    SharePoint site URL (e.g., https://contoso.sharepoint.com/sites/kb)

.PARAMETER Title
    Article title

.PARAMETER Summary
    Brief article summary

.PARAMETER Category
    Knowledge category (term path, e.g., "M365/Teams")

.PARAMETER UseTemplate
    Template to use: "MasterArticle" or "QuickReference" (default: MasterArticle)

.PARAMETER PublishImmediately
    Publish the article immediately (default: save as draft)

.EXAMPLE
    .\New-KBArticle.ps1 -SiteUrl "https://contoso.sharepoint.com/sites/kb" -Title "Enable Teams Meeting" -Category "M365/Teams"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$SiteUrl,
    
    [Parameter(Mandatory=$false)]
    [string]$Title,
    
    [Parameter(Mandatory=$false)]
    [string]$Summary,
    
    [Parameter(Mandatory=$false)]
    [string]$Category,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('MasterArticle','QuickReference')]
    [string]$UseTemplate = 'MasterArticle',
    
    [Parameter(Mandatory=$false)]
    [switch]$PublishImmediately
)

#Requires -Modules PnP.PowerShell

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Get-UserInput {
    param([string]$Prompt, [string]$Default = "")
    
    if ($Default) {
        $input = Read-Host "$Prompt [$Default]"
        if (-not $input) { return $Default }
        return $input
    } else {
        return Read-Host $Prompt
    }
}

# Main execution
try {
    Write-ColorOutput "`n========================================" "Cyan"
    Write-ColorOutput "Create New Knowledge Base Article" "Cyan"
    Write-ColorOutput "========================================`n" "Cyan"
    
    # Connect to SharePoint
    Write-ColorOutput "Connecting to SharePoint..." "Yellow"
    Connect-PnPOnline -Url $SiteUrl -Interactive
    Write-ColorOutput "Connected successfully!`n" "Green"
    
    # Interactive prompts if parameters not provided
    if (-not $Title) {
        $Title = Get-UserInput "Article Title"
    }
    
    if (-not $Summary) {
        $Summary = Get-UserInput "Article Summary (brief description)"
    }
    
    if (-not $Category) {
        Write-ColorOutput "`nAvailable categories:" "Yellow"
        Write-ColorOutput "  M365/Teams - Microsoft Teams" "Gray"
        Write-ColorOutput "  M365/OneDrive - OneDrive for Business" "Gray"
        Write-ColorOutput "  M365/SharePoint - SharePoint Online" "Gray"
        Write-ColorOutput "  AI/Copilot Chat - Copilot conversational AI" "Gray"
        Write-ColorOutput "  Development/Power Platform - Power Apps, Automate, BI" "Gray"
        Write-ColorOutput "  Security/Identity Management - Azure AD & Governance" "Gray"
        
        $Category = Get-UserInput "`nKnowledge Category (e.g., 'M365/Teams')"
    }
    
    # Generate file name from title
    $fileName = ($Title -replace '[^a-zA-Z0-9\s]', '' -replace '\s+', '-').ToLower()
    $fileName = "$fileName.aspx"
    
    Write-ColorOutput "`nCreating article: $Title" "Yellow"
    Write-ColorOutput "File name: $fileName" "Gray"
    Write-ColorOutput "Category: $Category" "Gray"
    Write-ColorOutput "Template: $UseTemplate`n" "Gray"
    
    # Get template page
    $templateFileName = if ($UseTemplate -eq 'MasterArticle') { 
        'template-master-article.aspx' 
    } else { 
        'template-quick-reference.aspx' 
    }
    
    # Create new page
    Write-ColorOutput "Creating page from template..." "Yellow"
    
    $page = Add-PnPPage -Name $fileName `
        -LayoutType Article `
        -Publish:$PublishImmediately
    
    # Add basic content structure
    Add-PnPPageTextPart -Page $page -Text "<h1>$Title</h1>"
    Add-PnPPageTextPart -Page $page -Text "<h2>Overview</h2><p>$Summary</p>"
    Add-PnPPageTextPart -Page $page -Text "<h2>Prerequisites</h2><ul><li>Prerequisite 1</li><li>Prerequisite 2</li></ul>"
    Add-PnPPageTextPart -Page $page -Text "<h2>Step-by-Step Instructions</h2><h3>Step 1:</h3><p>Instructions...</p>"
    
    Write-ColorOutput "Page created successfully!" "Green"
    
    # Set metadata
    Write-ColorOutput "Setting metadata..." "Yellow"
    
    $pageItem = Get-PnPListItem -List "Site Pages" -Id $page.PageId
    
    # Parse category path
    $categoryParts = $Category -split '/'
    if ($categoryParts.Count -eq 2) {
        $termPath = "KB Structure|$($categoryParts[0])|$($categoryParts[1])"
    } else {
        $termPath = "KB Structure|$Category"
    }
    
    # Set field values
    try {
        Set-PnPListItem -List "Site Pages" -Identity $page.PageId -Values @{
            "Title" = $Title
            "ArticleSummary" = $Summary
            "LastReviewDate" = (Get-Date).ToString("yyyy-MM-dd")
        } | Out-Null
        
        # Set taxonomy field (requires special handling)
        try {
            $taxonomyField = Get-PnPField -List "Site Pages" -Identity "KnowledgeCategory"
            $term = Get-PnPTerm -TermSet "KB Structure" -Term $categoryParts[-1]
            
            if ($term) {
                Set-PnPTaxonomyFieldValue -ListItem $pageItem `
                    -InternalFieldName "KnowledgeCategory" `
                    -TermId $term.Id
                
                Write-ColorOutput "Metadata set successfully!" "Green"
            }
        }
        catch {
            Write-ColorOutput "Could not set category automatically. Please set manually." "Yellow"
        }
    }
    catch {
        Write-ColorOutput "Warning: Some metadata fields could not be set" "Yellow"
    }
    
    # Get page URL
    $pageUrl = "$SiteUrl/SitePages/$fileName"
    
    Write-ColorOutput "`n========================================" "Cyan"
    Write-ColorOutput "Article Created Successfully!" "Green"
    Write-ColorOutput "========================================" "Cyan"
    Write-ColorOutput "Title: $Title" "White"
    Write-ColorOutput "URL: $pageUrl" "White"
    Write-ColorOutput "Status: $(if ($PublishImmediately) { 'Published' } else { 'Draft' })" "White"
    Write-ColorOutput "========================================`n" "Cyan"
    
    # Ask to open in browser
    $openBrowser = Get-UserInput "Open article in browser? (y/n)" "y"
    
    if ($openBrowser -eq 'y' -or $openBrowser -eq 'Y') {
        Start-Process $pageUrl
        Write-ColorOutput "Opening article in default browser...`n" "Yellow"
    }
    
    Write-ColorOutput "Next steps:" "Yellow"
    Write-ColorOutput "1. Edit the article content in SharePoint" "Gray"
    Write-ColorOutput "2. Add screenshots and images" "Gray"
    Write-ColorOutput "3. $(if (-not $PublishImmediately) { 'Publish the article when ready' } else { 'Article is already published!' })" "Gray"
    Write-ColorOutput "" "White"
    
    # Disconnect
    Disconnect-PnPOnline
}
catch {
    Write-ColorOutput "`nError creating article: $_" "Red"
    Write-ColorOutput $_.Exception.Message "Red"
    
    try { Disconnect-PnPOnline -ErrorAction SilentlyContinue } catch {}
    
    exit 1
}

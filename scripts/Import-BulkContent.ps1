<#
.SYNOPSIS
    Import bulk content to Knowledge Base from CSV or JSON

.DESCRIPTION
    Migrates multiple articles from CSV/JSON source files to SharePoint Knowledge Base.
    Supports automatic metadata assignment and HTML conversion.

.PARAMETER SiteUrl
    SharePoint site URL

.PARAMETER SourceFile
    Path to CSV or JSON file containing articles

.PARAMETER SourceType
    File type: CSV or JSON (default: auto-detect from extension)

.PARAMETER PublishArticles
    Publish articles immediately after import (default: save as drafts)

.EXAMPLE
    .\Import-BulkContent.ps1 -SiteUrl "https://contoso.sharepoint.com/sites/kb" -SourceFile "./articles.csv"

.EXAMPLE
    .\Import-BulkContent.ps1 -SiteUrl "https://contoso.sharepoint.com/sites/kb" -SourceFile "./articles.json" -PublishArticles
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$SiteUrl,
    
    [Parameter(Mandatory=$true)]
    [string]$SourceFile,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('CSV','JSON','Auto')]
    [string]$SourceType = 'Auto',
    
    [Parameter(Mandatory=$false)]
    [switch]$PublishArticles
)

#Requires -Modules PnP.PowerShell

# Initialize logging
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logPath = Join-Path $PSScriptRoot "../logs"
if (-not (Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}
$logFile = Join-Path $logPath "Import-Bulk-$timestamp.log"
$reportFile = Join-Path $logPath "Import-Report-$timestamp.csv"

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
    Write-Log "Bulk Content Import Started" -Level Info
    Write-Log "========================================" -Level Info
    
    # Validate source file
    if (-not (Test-Path $SourceFile)) {
        throw "Source file not found: $SourceFile"
    }
    
    # Determine file type
    if ($SourceType -eq 'Auto') {
        $extension = [System.IO.Path]::GetExtension($SourceFile)
        $SourceType = if ($extension -eq '.json') { 'JSON' } else { 'CSV' }
    }
    
    Write-Log "Source file: $SourceFile" -Level Info
    Write-Log "Source type: $SourceType" -Level Info
    
    # Load articles
    $articles = @()
    
    if ($SourceType -eq 'CSV') {
        $articles = Import-Csv -Path $SourceFile
        Write-Log "Loaded $($articles.Count) articles from CSV" -Level Success
    } else {
        $jsonContent = Get-Content -Path $SourceFile -Raw | ConvertFrom-Json
        $articles = $jsonContent.articles
        Write-Log "Loaded $($articles.Count) articles from JSON" -Level Success
    }
    
    # Connect to SharePoint
    Write-Log "Connecting to SharePoint: $SiteUrl" -Level Info
    Connect-PnPOnline -Url $SiteUrl -Interactive
    Write-Log "Connected successfully" -Level Success
    
    # Import articles
    $importResults = @()
    $successCount = 0
    $failCount = 0
    
    foreach ($article in $articles) {
        $title = $article.Title
        Write-Log "Processing: $title" -Level Info
        
        try {
            # Generate file name
            $fileName = ($title -replace '[^a-zA-Z0-9\s]', '' -replace '\s+', '-').ToLower()
            $fileName = "$fileName.aspx"
            
            # Check if article already exists
            $existing = Get-PnPListItem -List "Site Pages" `
                -Query "<View><Query><Where><Eq><FieldRef Name='FileLeafRef'/><Value Type='File'>$fileName</Value></Eq></Where></Query></View>" `
                -ErrorAction SilentlyContinue
            
            if ($existing) {
                Write-Log "  Article already exists, skipping: $fileName" -Level Warning
                $importResults += [PSCustomObject]@{
                    Title = $title
                    FileName = $fileName
                    Status = "Skipped (Already Exists)"
                    Error = ""
                }
                continue
            }
            
            # Create page
            $page = Add-PnPPage -Name $fileName `
                -LayoutType Article `
                -Publish:$PublishArticles
            
            # Add content
            if ($article.Content) {
                # Convert markdown to HTML if needed
                $content = $article.Content
                
                # Simple markdown conversion (for basic formatting)
                $content = $content -replace '\*\*(.+?)\*\*', '<strong>$1</strong>'
                $content = $content -replace '\*(.+?)\*', '<em>$1</em>'
                $content = $content -replace '^# (.+)$', '<h1>$1</h1>'
                $content = $content -replace '^## (.+)$', '<h2>$1</h2>'
                $content = $content -replace '^### (.+)$', '<h3>$1</h3>'
                
                Add-PnPPageTextPart -Page $page -Text $content
            }
            
            # Set metadata
            $values = @{
                "Title" = $title
                "ArticleSummary" = $article.Summary
                "LastReviewDate" = (Get-Date).ToString("yyyy-MM-dd")
            }
            
            Set-PnPListItem -List "Site Pages" -Identity $page.PageId -Values $values | Out-Null
            
            # Set category if provided
            if ($article.Category) {
                try {
                    $categoryParts = $article.Category -split '/'
                    $term = Get-PnPTerm -TermSet "KB Structure" -Term $categoryParts[-1] -ErrorAction SilentlyContinue
                    
                    if ($term) {
                        $pageItem = Get-PnPListItem -List "Site Pages" -Id $page.PageId
                        Set-PnPTaxonomyFieldValue -ListItem $pageItem `
                            -InternalFieldName "KnowledgeCategory" `
                            -TermId $term.Id
                    }
                }
                catch {
                    Write-Log "  Could not set category: $($article.Category)" -Level Warning
                }
            }
            
            Write-Log "  Created successfully: $fileName" -Level Success
            $successCount++
            
            $importResults += [PSCustomObject]@{
                Title = $title
                FileName = $fileName
                Status = if ($PublishArticles) { "Published" } else { "Draft" }
                Error = ""
            }
        }
        catch {
            Write-Log "  Failed to import: $_" -Level Error
            $failCount++
            
            $importResults += [PSCustomObject]@{
                Title = $title
                FileName = ""
                Status = "Failed"
                Error = $_.Exception.Message
            }
        }
    }
    
    # Generate report
    $importResults | Export-Csv -Path $reportFile -NoTypeInformation
    
    Write-Log "========================================" -Level Info
    Write-Log "Bulk Content Import Completed" -Level Success
    Write-Log "========================================" -Level Info
    Write-Log "Total articles processed: $($articles.Count)" -Level Info
    Write-Log "Successfully imported: $successCount" -Level Success
    Write-Log "Failed: $failCount" -Level $(if ($failCount -gt 0) { "Error" } else { "Info" })
    Write-Log "Report saved to: $reportFile" -Level Info
    Write-Log "========================================" -Level Info
    
    # Disconnect
    Disconnect-PnPOnline
}
catch {
    Write-Log "========================================" -Level Error
    Write-Log "Bulk Content Import Failed" -Level Error
    Write-Log $_.Exception.Message -Level Error
    Write-Log "========================================" -Level Error
    
    try { Disconnect-PnPOnline -ErrorAction SilentlyContinue } catch {}
    
    exit 1
}

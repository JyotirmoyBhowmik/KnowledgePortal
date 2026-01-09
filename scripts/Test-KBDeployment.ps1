<#
.SYNOPSIS
    Validation and testing script for Knowledge Base deployment

.DESCRIPTION
    Validates that all components of the Knowledge Base are properly configured
    and generates a comprehensive validation report.

.PARAMETER SiteUrl
    SharePoint site URL

.PARAMETER GenerateReport
    Generate HTML report of validation results

.EXAMPLE
    .\Test-KBDeployment.ps1 -SiteUrl "https://contoso.sharepoint.com/sites/kb" -GenerateReport
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$SiteUrl,
    
    [Parameter(Mandatory=$false)]
    [switch]$GenerateReport
)

#Requires -Modules PnP.PowerShell

# Initialize
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logPath = Join-Path $PSScriptRoot "../logs"
if (-not (Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}
$logFile = Join-Path $logPath "Test-KB-$timestamp.log"

$testResults = @()

function Write-Log {
    param([string]$Message, [string]$Level = 'Info')
    
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

function Test-Component {
    param([string]$Name, [scriptblock]$TestScript)
    
    Write-Log "Testing: $Name" -Level Info
    
    try {
        $result = & $TestScript
        
        if ($result) {
            Write-Log "  PASS: $Name" -Level Success
            $script:testResults += [PSCustomObject]@{
                Component = $Name
                Status = "PASS"
                Details = "OK"
            }
            return $true
        } else {
            Write-Log "  FAIL: $Name" -Level Error
            $script:testResults += [PSCustomObject]@{
                Component = $Name
                Status = "FAIL"
                Details = "Check failed"
            }
            return $false
        }
    }
    catch {
        Write-Log "  FAIL: $Name - $_" -Level Error
        $script:testResults += [PSCustomObject]@{
            Component = $Name
            Status = "FAIL"
            Details = $_.Exception.Message
        }
        return $false
    }
}

# Main execution
try {
    Write-Log "========================================" -Level Info
    Write-Log "Knowledge Base Validation Started" -Level Info
    Write-Log "========================================" -Level Info
    
    # Connect
    Write-Log "Connecting to: $SiteUrl" -Level Info
    Connect-PnPOnline -Url $SiteUrl -Interactive
    Write-Log "Connected successfully`n" -Level Success
    
    # Test 1: Site exists and is accessible
    Test-Component "Site Accessibility" {
        $web = Get-PnPWeb
        return ($null -ne $web)
    }
    
    # Test 2: Site Pages library exists
    Test-Component "Site Pages Library" {
        $list = Get-PnPList -Identity "Site Pages"
        return ($null -ne $list)
    }
    
    # Test 3: Custom columns exist
    Test-Component "KnowledgeCategory Column" {
        $field = Get-PnPField -List "Site Pages" -Identity "KnowledgeCategory" -ErrorAction SilentlyContinue
        return ($null -ne $field)
    }
    
    Test-Component "ArticleSummary Column" {
        $field = Get-PnPField -List "Site Pages" -Identity "ArticleSummary" -ErrorAction SilentlyContinue
        return ($null -ne $field)
    }
    
    Test-Component "LastReviewDate Column" {
        $field = Get-PnPField -List "Site Pages" -Identity "LastReviewDate" -ErrorAction SilentlyContinue
        return ($null -ne $field)
    }
    
    # Test 4: Security groups exist
    Test-Component "KB Visitors Group" {
        $group = Get-PnPGroup -Identity "KB Visitors" -ErrorAction SilentlyContinue
        return ($null -ne $group)
    }
    
    Test-Component "KB Members Group" {
        $group = Get-PnPGroup -Identity "KB Members" -ErrorAction SilentlyContinue
        return ($null -ne $group)
    }
    
    Test-Component "KB Owners Group" {
        $group = Get-PnPGroup -Identity "KB Owners" -ErrorAction SilentlyContinue
        return ($null -ne $group)
    }
    
    # Test 5: Template pages exist
    Test-Component "Master Article Template" {
        $page = Get-PnPListItem -List "Site Pages" `
            -Query "<View><Query><Where><Contains><FieldRef Name='FileLeafRef'/><Value Type='File'>template-master</Value></Contains></Where></Query></View>" `
            -ErrorAction SilentlyContinue
        return ($null -ne $page -and $page.Count -gt 0)
    }
    
    # Test 6: Versioning enabled
    Test-Component "Versioning Configuration" {
        $list = Get-PnPList -Identity "Site Pages"
        return ($list.EnableVersioning -eq $true)
    }
    
    # Test 7: Term Store configuration
    Test-Component "Term Store Connection" {
        try {
            $ctx = Get-PnPContext
            $taxSession = [Microsoft.SharePoint.Client.Taxonomy.TaxonomySession]::GetTaxonomySession($ctx)
            $ctx.Load($taxSession)
            $ctx.ExecuteQuery()
            return $true
        }
        catch {
            return $false
        }
    }
    
    # Generate summary
    Write-Log "`n========================================" -Level Info
    Write-Log "Validation Summary" -Level Info
    Write-Log "========================================" -Level Info
    
    $passCount = ($testResults | Where-Object { $_.Status -eq "PASS" }).Count
    $failCount = ($testResults | Where-Object { $_.Status -eq "FAIL" }).Count
    $totalTests = $testResults.Count
    
    Write-Log "Total Tests: $totalTests" -Level Info
    Write-Log "Passed: $passCount" -Level Success
    Write-Log "Failed: $failCount" -Level $(if ($failCount -gt 0) { "Error" } else { "Info" })
    
    $passRate = [math]::Round(($passCount / $totalTests) * 100, 2)
    Write-Log "Success Rate: $passRate%" -Level $(if ($passRate -ge 80) { "Success" } else { "Warning" })
    
    # Save report
    if ($GenerateReport) {
        $reportFile = Join-Path $logPath "ValidationReport-$timestamp.html"
        
        $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>KB Validation Report</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; padding: 20px; }
        h1 { color: #0078d4; }
        .summary { background: #f3f2f1; padding: 15px; border-radius: 5px; margin: 20px 0; }
        table { border-collapse: collapse; width: 100%; margin: 20px 0; }
        th { background: #0078d4; color: white; padding: 12px; text-align: left; }
        td { padding: 10px; border-bottom: 1px solid #ddd; }
        .pass { color: green; font-weight: bold; }
        .fail { color: red; font-weight: bold; }
    </style>
</head>
<body>
    <h1>Knowledge Base Validation Report</h1>
    <div class="summary">
        <h2>Summary</h2>
        <p><strong>Site URL:</strong> $SiteUrl</p>
        <p><strong>Test Date:</strong> $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
        <p><strong>Total Tests:</strong> $totalTests</p>
        <p><strong>Passed:</strong> <span class="pass">$passCount</span></p>
        <p><strong>Failed:</strong> <span class="fail">$failCount</span></p>
        <p><strong>Success Rate:</strong> $passRate%</p>
    </div>
    <h2>Test Results</h2>
    <table>
        <tr>
            <th>Component</th>
            <th>Status</th>
            <th>Details</th>
        </tr>
"@
        
        foreach ($result in $testResults) {
            $statusClass = $result.Status.ToLower()
            $html += @"
        <tr>
            <td>$($result.Component)</td>
            <td class="$statusClass">$($result.Status)</td>
            <td>$($result.Details)</td>
        </tr>
"@
        }
        
        $html += @"
    </table>
</body>
</html>
"@
        
        $html | Out-File -FilePath $reportFile -Encoding UTF8
        Write-Log "`nHTML report generated: $reportFile" -Level Success
    }
    
    Write-Log "========================================`n" -Level Info
    
    # Disconnect
    Disconnect-PnPOnline
    
    # Exit code based on results
    if ($failCount -eq 0) {
        exit 0
    } else {
        exit 1
    }
}
catch {
    Write-Log "========================================" -Level Error
    Write-Log "Validation Failed" -Level Error
    Write-Log $_.Exception.Message -Level Error
    Write-Log "========================================" -Level Error
    
    try { Disconnect-PnPOnline -ErrorAction SilentlyContinue } catch {}
    
    exit 1
}

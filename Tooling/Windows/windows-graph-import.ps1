# Microsoft Graph Module Import Script for Windows
# This script imports only Microsoft Graph-related PowerShell modules

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Please run this script as Administrator" -ForegroundColor Red
    exit
}

# Set execution policy to allow script execution
try {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
    Write-Host "Execution policy set successfully" -ForegroundColor Green
}
catch {
    Write-Host "Warning: Could not set execution policy. Continuing with current policy." -ForegroundColor Yellow
}

# Define Microsoft Graph modules
$graphModules = @(
    "Microsoft.Graph",
    "Microsoft.Graph.Authentication",
    "Microsoft.Graph.Identity.DirectoryManagement",
    "Microsoft.Graph.Users",
    "Microsoft.Graph.Groups",
    "Microsoft.Graph.Teams",
    "Microsoft.Graph.Sites",
    "Microsoft.Graph.Identity.Governance",
    "Microsoft.Graph.Identity.SignIns",
    "Microsoft.Graph.Reports"
)

# Function to import modules with error handling
function Import-ModuleWithRetry {
    param (
        [string]$moduleName,
        [int]$maxRetries = 3
    )
    
    $retryCount = 0
    $success = $false
    
    while (-not $success -and $retryCount -lt $maxRetries) {
        try {
            Write-Host "Importing module: $moduleName" -ForegroundColor Green
            Import-Module -Name $moduleName -Force -ErrorAction Stop
            Write-Host "Successfully imported $moduleName" -ForegroundColor Green
            $success = $true
        }
        catch {
            $retryCount++
            if ($retryCount -eq $maxRetries) {
                Write-Host "Failed to import $moduleName after $maxRetries attempts. Error: $_" -ForegroundColor Red
            } else {
                Write-Host "Retry $retryCount of $maxRetries for $moduleName..." -ForegroundColor Yellow
                Start-Sleep -Seconds 2
            }
        }
    }
}

# Import Microsoft Graph modules
Write-Host "`nImporting Microsoft Graph modules..." -ForegroundColor Yellow
foreach ($module in $graphModules) {
    Import-ModuleWithRetry -moduleName $module
}

# Verify imports
Write-Host "`nVerifying module imports..." -ForegroundColor Yellow
foreach ($module in $graphModules) {
    if (Get-Module -Name $module) {
        Write-Host "$module is imported" -ForegroundColor Green
    }
    else {
        Write-Host "$module is NOT imported" -ForegroundColor Red
    }
}

# Display available commands
Write-Host "`nAvailable Microsoft Graph commands:" -ForegroundColor Yellow
Get-Command -Module $graphModules | Group-Object -Property Source | Select-Object Name, Count | Sort-Object Count -Descending | Format-Table -AutoSize

Write-Host "`nMicrosoft Graph module import complete!" -ForegroundColor Green
Write-Host "Microsoft Graph modules have been imported and are ready to use." -ForegroundColor Yellow 

# Azure Red Team Module Cleanup Script for Windows
# This script removes all installed components from the Azure red team tooling

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Please run this script as Administrator" -ForegroundColor Red
    exit
}

# Define base directory
$baseDir = "C:\dontscan\azure-cloud"

# Define modules to uninstall
$modulesToUninstall = @(
    # Azure Modules
    "Az",
    "Az.Accounts",
    "Az.Resources",
    "Az.KeyVault",
    "Az.Storage",
    "Az.Websites",
    "Az.Functions",
    "Az.Compute",
    "Az.Network",
    "Az.Monitor",
    "Az.OperationalInsights",
    "Az.Security",
    
    # Additional Security Modules
    "Microsoft.Graph",
    "Microsoft.Graph.Authentication",
    "Microsoft.Graph.Identity.DirectoryManagement",
    "Microsoft.Graph.Users",
    "Microsoft.Graph.Groups",
    "Microsoft.Graph.Teams",
    "Microsoft.Graph.Sites",
    "Microsoft.Graph.Identity.Governance",
    "Microsoft.Graph.Identity.SignIns",
    "Microsoft.Graph.Reports",
    
    # Legacy Azure AD Modules
    "AzureAD",
    "AzureADPreview",
    "MSOnline",
    
    # Utility Modules
    "PSFramework",
    "PSModuleDevelopment",
    "PSFTP",
    "PSScriptAnalyzer"
)

# Check for installed modules
Write-Host "`nChecking installed PowerShell modules..." -ForegroundColor Yellow
$installedModules = @()
foreach ($module in $modulesToUninstall) {
    $installedModule = Get-Module -ListAvailable -Name $module
    if ($installedModule) {
        # Check if module is built-in
        $isBuiltIn = $installedModule.Path -like "$env:SystemRoot\*"
        if (-not $isBuiltIn) {
            $installedModules += @{
                Name = $module
                Version = $installedModule.Version
                Path = $installedModule.Path
            }
            Write-Host "Found $module (Version: $($installedModule.Version))" -ForegroundColor Green
        }
        else {
            Write-Host "Skipping built-in module: $module" -ForegroundColor Yellow
        }
    }
}

# Check for loaded modules
Write-Host "`nChecking loaded PowerShell modules..." -ForegroundColor Yellow
$loadedModules = Get-Module | Where-Object { $modulesToUninstall -contains $_.Name }
foreach ($module in $loadedModules) {
    Write-Host "Module $($module.Name) is currently loaded" -ForegroundColor Yellow
}

# Uninstall PowerShell modules
if ($installedModules.Count -gt 0) {
    Write-Host "`nUninstalling PowerShell modules..." -ForegroundColor Yellow
    foreach ($module in $installedModules) {
        Write-Host "Uninstalling module: $($module.Name) (Version: $($module.Version))" -ForegroundColor Yellow
        try {
            Uninstall-Module -Name $module.Name -AllVersions -Force -ErrorAction Stop
            Write-Host "Successfully uninstalled $($module.Name)" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to uninstall $($module.Name). Error: $_" -ForegroundColor Red
        }
    }
}
else {
    Write-Host "`nNo PowerShell modules found to uninstall" -ForegroundColor Yellow
}

# Define GitHub tools to check
$githubTools = @(
    @{
        Name = "MSOLSpray"
        Path = Join-Path $baseDir "Modules\MSOLSpray"
    },
    @{
        Name = "AADInternals"
        Path = Join-Path $baseDir "Modules\AADInternals"
    },
    @{
        Name = "TokenTacticsV2"
        Path = Join-Path $baseDir "Modules\TokenTacticsV2"
    },
    @{
        Name = "GraphRunner"
        Path = Join-Path $baseDir "Modules\GraphRunner"
    }
)

# Check for installed GitHub tools
Write-Host "`nChecking installed GitHub tools..." -ForegroundColor Yellow
$installedGithubTools = @()
foreach ($tool in $githubTools) {
    if (Test-Path $tool.Path) {
        $installedGithubTools += $tool
        Write-Host "Found $($tool.Name) at $($tool.Path)" -ForegroundColor Green
    }
}

# Remove GitHub tools
if ($installedGithubTools.Count -gt 0) {
    Write-Host "`nRemoving GitHub tools..." -ForegroundColor Yellow
    foreach ($tool in $installedGithubTools) {
        Write-Host "Removing $($tool.Name)..." -ForegroundColor Yellow
        try {
            Remove-Item -Path $tool.Path -Recurse -Force
            Write-Host "Successfully removed $($tool.Name)" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to remove $($tool.Name). Error: $_" -ForegroundColor Red
        }
    }
}
else {
    Write-Host "`nNo GitHub tools found to remove" -ForegroundColor Yellow
}

# Define Python tools to check
$pythonTools = @(
    @{
        Name = "AzSubEnum"
        Path = Join-Path $baseDir "Python\AzSubEnum"
    },
    @{
        Name = "Oh365UserFinder"
        Path = Join-Path $baseDir "Python\Oh365UserFinder"
    },
    @{
        Name = "BasicBlobFinder"
        Path = Join-Path $baseDir "Python\BasicBlobFinder"
    }
)

# Check for installed Python tools
Write-Host "`nChecking installed Python tools..." -ForegroundColor Yellow
$installedPythonTools = @()
foreach ($tool in $pythonTools) {
    if (Test-Path $tool.Path) {
        $installedPythonTools += $tool
        Write-Host "Found $($tool.Name) at $($tool.Path)" -ForegroundColor Green
    }
}

# Remove Python tools
if ($installedPythonTools.Count -gt 0) {
    Write-Host "`nRemoving Python tools..." -ForegroundColor Yellow
    foreach ($tool in $installedPythonTools) {
        Write-Host "Removing $($tool.Name)..." -ForegroundColor Yellow
        try {
            Remove-Item -Path $tool.Path -Recurse -Force
            Write-Host "Successfully removed $($tool.Name)" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to remove $($tool.Name). Error: $_" -ForegroundColor Red
        }
    }
}
else {
    Write-Host "`nNo Python tools found to remove" -ForegroundColor Yellow
}

# Check base directory
if (Test-Path $baseDir) {
    $isEmpty = (Get-ChildItem -Path $baseDir -Recurse | Measure-Object).Count -eq 0
    if ($isEmpty) {
        Write-Host "`nBase directory is empty. Removing..." -ForegroundColor Yellow
        try {
            Remove-Item -Path $baseDir -Recurse -Force
            Write-Host "Successfully removed base directory" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to remove base directory. Error: $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "`nBase directory is not empty. Contents:" -ForegroundColor Yellow
        Get-ChildItem -Path $baseDir -Recurse | ForEach-Object {
            Write-Host $_.FullName -ForegroundColor Yellow
        }
    }
}

# Reset execution policy
try {
    Set-ExecutionPolicy -ExecutionPolicy Restricted -Scope LocalMachine -Force
    Write-Host "`nExecution policy reset successfully" -ForegroundColor Green
}
catch {
    Write-Host "`nWarning: Could not reset execution policy. Error: $_" -ForegroundColor Yellow
}

Write-Host "`nCleanup complete!" -ForegroundColor Green 

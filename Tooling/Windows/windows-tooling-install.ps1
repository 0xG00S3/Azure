# Azure Red Team Module Installation Script for Windows
# This script installs all PowerShell modules required for Azure red team operations on Windows

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

# Define base directory
$baseDir = "C:\dontscan\azure-cloud"

# Create directory structure
$directories = @(
    "$baseDir\Modules",
    "$baseDir\Tools",
    "$baseDir\Python",
    "$baseDir\Ruby",
    "$baseDir\Go"
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "Created directory: $dir" -ForegroundColor Green
    }
}

# Define required modules
$requiredModules = @(
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

# Install each module
foreach ($module in $requiredModules) {
    Write-Host "Checking module: $module" -ForegroundColor Green
    try {
        $installedModule = Get-Module -Name $module -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
        if ($installedModule) {
            Write-Host "Module $module is installed (Version: $($installedModule.Version))" -ForegroundColor Yellow
            
            # Check for updates
            $latestVersion = Find-Module -Name $module -ErrorAction SilentlyContinue
            if ($latestVersion -and $latestVersion.Version -gt $installedModule.Version) {
                Write-Host "Updating $module from $($installedModule.Version) to $($latestVersion.Version)..." -ForegroundColor Yellow
                Update-Module -Name $module -Force -ErrorAction Stop
                Write-Host "Successfully updated $module" -ForegroundColor Green
            } else {
                Write-Host "Module $module is up to date" -ForegroundColor Green
            }
        }
        else {
            Write-Host "Installing $module..." -ForegroundColor Yellow
            Install-Module -Name $module -Force -AllowClobber -Scope AllUsers -ErrorAction Stop
            Write-Host "Successfully installed $module" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "Failed to process $module. Error: $_" -ForegroundColor Red
    }
}

# Define GitHub tools
$githubTools = @(
    @{
        Name = "MSOLSpray"
        Repo = "dafthack/MSOLSpray"
        Path = "$baseDir\Modules\MSOLSpray"
    },
    @{
        Name = "AADInternals"
        Repo = "Gerenios/AADInternals"
        Path = "$baseDir\Modules\AADInternals"
        Branch = "master"
    },
    @{
        Name = "TokenTacticsV2"
        Repo = "f-bader/TokenTacticsV2"
        Path = "$baseDir\Modules\TokenTacticsV2"
    },
    @{
        Name = "GraphRunner"
        Repo = "dafthack/GraphRunner"
        Path = "$baseDir\Modules\GraphRunner"
    }
)

# Install GitHub tools
foreach ($tool in $githubTools) {
    Write-Host "Installing $($tool.Name) from GitHub..." -ForegroundColor Green
    try {
        if (Test-Path $tool.Path) {
            Write-Host "$($tool.Name) is already installed. Skipping..." -ForegroundColor Yellow
            continue
        }

        $tempDir = Join-Path $env:TEMP $tool.Name
        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force
        }

        # Clone the repository
        if ($tool.Branch) {
            git clone -b $tool.Branch "https://github.com/$($tool.Repo).git" $tempDir
        } else {
            git clone "https://github.com/$($tool.Repo).git" $tempDir
        }
        
        if (Test-Path $tempDir) {
            # Create destination directory if it doesn't exist
            if (-not (Test-Path $tool.Path)) {
                New-Item -ItemType Directory -Path $tool.Path -Force | Out-Null
            }
            
            # Copy files to destination
            Copy-Item -Path "$tempDir\*" -Destination $tool.Path -Recurse -Force
            
            # Clean up temp directory
            Remove-Item -Path $tempDir -Recurse -Force
            
            Write-Host "Successfully installed $($tool.Name)" -ForegroundColor Green
        }
        else {
            Write-Host "Failed to install $($tool.Name) - Repository not cloned" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Failed to install $($tool.Name). Error: $_" -ForegroundColor Red
    }
}

# Download and replace SATOCerts.ps1
$satoCertsUrl = "https://raw.githubusercontent.com/0xG00S3/Azure/refs/heads/main/Tooling/SATOCerts.ps1"
$satoCertsPath = "$baseDir\Modules\SATO\SATOCerts.ps1"

Write-Host "Downloading updated SATOCerts.ps1..." -ForegroundColor Green
try {
    # Create SATO directory if it doesn't exist
    $satoDir = Split-Path -Parent $satoCertsPath
    if (-not (Test-Path $satoDir)) {
        New-Item -ItemType Directory -Path $satoDir -Force | Out-Null
    }

    # Download the file
    Invoke-WebRequest -Uri $satoCertsUrl -OutFile $satoCertsPath
    Write-Host "Successfully downloaded and replaced SATOCerts.ps1" -ForegroundColor Green
}
catch {
    Write-Host "Failed to download SATOCerts.ps1. Error: $_" -ForegroundColor Red
}

# Define Python tools
$pythonTools = @(
    @{
        Name = "AzSubEnum"
        Repo = "yuyudhn/AzSubEnum"
        Path = "$baseDir\Python\AzSubEnum"
    },
    @{
        Name = "Oh365UserFinder"
        Repo = "dievus/Oh365UserFinder"
        Path = "$baseDir\Python\Oh365UserFinder"
    },
    @{
        Name = "BasicBlobFinder"
        Repo = "joswr1ght/basicblobfinder"
        Path = "$baseDir\Python\BasicBlobFinder"
    }
)

# Install Python tools
foreach ($tool in $pythonTools) {
    Write-Host "Installing $($tool.Name) from GitHub..." -ForegroundColor Green
    try {
        if (Test-Path $tool.Path) {
            Write-Host "$($tool.Name) is already installed. Skipping..." -ForegroundColor Yellow
            continue
        }

        $tempDir = Join-Path $env:TEMP $tool.Name
        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force
        }

        # Clone the repository
        git clone "https://github.com/$($tool.Repo).git" $tempDir
        
        if (Test-Path $tempDir) {
            # Create destination directory if it doesn't exist
            if (-not (Test-Path $tool.Path)) {
                New-Item -ItemType Directory -Path $tool.Path -Force | Out-Null
            }
            
            # Copy files to destination
            Copy-Item -Path "$tempDir\*" -Destination $tool.Path -Recurse -Force
            
            # Clean up temp directory
            Remove-Item -Path $tempDir -Recurse -Force
            
            Write-Host "Successfully installed $($tool.Name)" -ForegroundColor Green
        }
        else {
            Write-Host "Failed to install $($tool.Name) - Repository not cloned" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Failed to install $($tool.Name). Error: $_" -ForegroundColor Red
    }
}

# Verify module installations
Write-Host "`nVerifying module installations..." -ForegroundColor Yellow
foreach ($module in $requiredModules) {
    $installedModule = Get-Module -Name $module -ListAvailable
    if ($installedModule) {
        Write-Host "$module is installed (Version: $($installedModule.Version))" -ForegroundColor Green
    }
    else {
        Write-Host "$module is NOT installed" -ForegroundColor Red
    }
}

# Verify GitHub tool installations
Write-Host "`nVerifying GitHub tool installations..." -ForegroundColor Yellow
foreach ($tool in $githubTools) {
    if (Test-Path $tool.Path) {
        Write-Host "$($tool.Name) is installed" -ForegroundColor Green
        # Additional verification for AADInternals
        if ($tool.Name -eq "AADInternals") {
            $modulePath = Join-Path $tool.Path "AADInternals.psm1"
            if (Test-Path $modulePath) {
                Write-Host "AADInternals module file found" -ForegroundColor Green
            } else {
                Write-Host "AADInternals module file not found" -ForegroundColor Red
            }
        }
    }
    else {
        Write-Host "$($tool.Name) is NOT installed" -ForegroundColor Red
    }
}

# Verify SATOCerts.ps1
if (Test-Path $satoCertsPath) {
    Write-Host "SATOCerts.ps1 is installed" -ForegroundColor Green
} else {
    Write-Host "SATOCerts.ps1 is NOT installed" -ForegroundColor Red
}

Write-Host "`nModule installation complete!" -ForegroundColor Green
Write-Host "Please run windows-import-modules.ps1 to import all modules." -ForegroundColor Yellow 

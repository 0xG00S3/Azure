# Azure Red Team Tooling for Linux

This repository contains setup scripts for Azure red team tooling on Linux systems. It creates a clean, organized environment for all your tools with proper module management and easy-to-use scripts.

## Prerequisites

- Linux (Ubuntu/Debian or RHEL/CentOS)
- PowerShell Core (pwsh)
- Python 3.8 or later
- Ruby 2.7 or later
- Git
- OpenSSL
- Build essentials
- Sudo access

## Directory Structure

```
/opt/az-rt-tools/
├── Modules/          # PowerShell modules
│   ├── MSOLSpray
│   ├── AADInternals
│   ├── TokenTacticsV2
│   ├── GraphRunner
│   └── SATO
├── Tools/           # General tools
├── Python/          # Python tools
│   ├── AzSubEnum
│   ├── Oh365UserFinder
│   └── BasicBlobFinder
├── Ruby/            # Ruby tools
└── Go/              # Go tools

/opt/venv/           # Virtual environments
/usr/local/share/powershell/Modules/  # Symbolic links to modules
```

## Installation

1. Install PowerShell Core:
```bash
# Ubuntu/Debian
wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y powershell

# RHEL/CentOS
sudo yum install -y https://packages.microsoft.com/config/rhel/7/packages-microsoft-prod.rpm
sudo yum install -y powershell
```

2. Run the installation script with sudo:
```bash
sudo pwsh -File ./install-modules-linux.ps1
```

The script will:
- Create necessary directories under `/opt/az-rt-tools`
- Install PowerShell modules
- Download and install GitHub tools
- Set up Python tools
- Install Ruby tools
- Create symbolic links for module access
- Set proper permissions
- Verify installations

## Usage

After installation, you can import all modules using:
```bash
pwsh -File ./linux-import-modules.ps1
```

### Common Commands

#### Azure Modules
```powershell
# Connect to Azure
Connect-AzAccount

# List resources
Get-AzResource

# Check role assignments
Get-AzRoleAssignment
```

#### Microsoft Graph
```powershell
# Connect to Graph
Connect-MgGraph

# List users
Get-MgUser

# Check group membership
Get-MgUserMemberOf
```

#### AADInternals
```powershell
# Get tenant information
Get-AADIntLoginInformation

# Check tenant ID
Get-AADIntTenantID
```

#### MSOLSpray
```powershell
# Password spray
Invoke-MSOLSpray -UserList users.txt -Password "password"
```

## Maintenance

### Updating Tools
To update all tools, simply run the installation script again:
```bash
sudo pwsh -File ./install-modules-linux.ps1
```

### Cleaning Up
To remove all installed components:
```bash
sudo ./cleanup.sh
```

The cleanup script will:
- Remove all PowerShell modules
- Remove all GitHub tools
- Remove all Python tools
- Remove all Ruby tools
- Remove all Go tools
- Clean up virtual environments
- Remove symbolic links
- Reset execution policy
- Clean up base directories if empty

Note: The cleanup script requires sudo privileges and will remove all installed components.

## Troubleshooting

### Common Issues

1. Module Installation Failures
   - Check internet connectivity
   - Verify PowerShell execution policy
   - Check for sufficient permissions
   - Ensure using sudo for installation

2. Certificate Issues
   - Verify certificate store access
   - Check certificate permissions
   - Validate certificate chain

3. Authentication Issues
   - Verify Azure CLI installation
   - Check token cache
   - Validate credentials

### Platform-Specific Issues

- PowerShell Core compatibility
- Certificate store access
- WinRM installation and configuration
- Sudo access requirements

## Security Considerations

1. Tool Installation
   - Verify tool sources
   - Check tool signatures
   - Use secure download methods
   - Use sudo only when necessary

2. Credential Management
   - Use secure credential storage
   - Implement proper access controls
   - Follow least privilege principle

3. Network Security
   - Use secure connections
   - Implement proper firewall rules
   - Monitor network traffic

## Additional Resources

- [Microsoft Graph API Documentation](https://learn.microsoft.com/en-us/graph/overview)
- [Azure CLI Documentation](https://learn.microsoft.com/en-us/cli/azure/)
- [PowerShell Core Documentation](https://learn.microsoft.com/en-us/powershell/)
- [Azure Security Documentation](https://learn.microsoft.com/en-us/azure/security/) 

# Azure Red Team Tooling for Linux

This repository contains setup scripts for Azure red team tooling on Linux systems. It creates a clean, organized environment for all your tools with virtual environments and easy-to-use launchers.

## Prerequisites

- Linux (Ubuntu/Debian or RHEL/CentOS)
- PowerShell Core (pwsh)
- Python 3.8 or later
- Ruby 2.7 or later
- Git
- OpenSSL
- Build essentials

## Directory Structure

```
~/.local/share/powershell/Modules/  # PowerShell modules
├── MSOLSpray
├── AADInternals
├── TokenTacticsV2
└── GraphRunner

~/Tools/
├── Python/
│   ├── AzSubEnum
│   ├── Oh365UserFinder
│   └── BasicBlobFinder
├── Ruby/
│   └── Evil-WinRM
└── Go/
    └── Evilginx
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

2. Make the setup script executable:
```bash
chmod +x setup.sh
```

3. Run the setup script:
```bash
./setup.sh
```

The script will:
- Create necessary directories
- Install PowerShell modules
- Set up Python virtual environments
- Install Ruby gems
- Install Go tools
- Create launcher scripts

## Usage

After installation, you can import all modules using:
```bash
pwsh -File ./import-modules-linux.ps1
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

#### Python Tools
```bash
# Run AzSubEnum
python3 ~/Tools/Python/AzSubEnum/azsubenum.py -b domain.com -t 10 -p 5

# Run Oh365UserFinder
python3 ~/Tools/Python/Oh365UserFinder/Oh365UserFinder.py -d domain.com -u users.txt

# Run BasicBlobFinder
python3 ~/Tools/Python/BasicBlobFinder/basicblobfinder.py namelist.txt
```

#### Ruby Tools
```bash
# Use Evil-WinRM
evil-winrm -i <ip> -u <user> -p <password>
```

## Maintenance

### Updating Tools
To update all tools, simply run the setup script again:
```bash
./setup.sh
```

### Cleaning Up
To remove all installed components:
```bash
./cleanup.sh
```

The cleanup script will:
- Uninstall all PowerShell modules
- Remove all GitHub tools
- Remove all Python tools
- Clean up virtual environments
- Remove Ruby gems
- Clean up the base directory if empty
- Reset execution policy

Note: The cleanup script will skip system-installed modules to prevent system issues.

## Troubleshooting

### Common Issues

1. Module Installation Failures
   - Check internet connectivity
   - Verify PowerShell execution policy
   - Check for sufficient permissions

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

## Security Considerations

1. Tool Installation
   - Verify tool sources
   - Check tool signatures
   - Use secure download methods

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

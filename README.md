# Azure
Azure Pentesting Resource


---

# Powershell Scripts

# token_polling.ps1

## Azure AD Device Code Authentication Token Harvester

A PowerShell script that demonstrates automated token acquisition using the Azure AD device code flow authentication. The script targets Microsoft's authentication endpoints to obtain access and refresh tokens that can be used for various Microsoft services (Graph API, Azure Resource Manager, etc.).

## Features
- Implements the complete OAuth 2.0 device code flow
- Automatically handles device code request and token polling
- Configurable resource endpoint targeting (Graph API, Azure RM, etc.)
- Built-in error handling and timeout management
- Retrieves both access and refresh tokens
- Uses the Azure PowerShell client ID for broad API access

## How it Works
1. Requests a device code from Azure AD's OAuth endpoint
2. Displays authentication URL and user code for sign-in
3. Continuously polls the token endpoint while waiting for user authentication
4. Upon successful authentication, retrieves and outputs the access token
5. Silently stores the refresh token for potential reuse

## Usage
The script defaults to Microsoft Graph API but can be modified to target other Microsoft API endpoints by changing the `$resource` variable:
- Microsoft Graph: `https://graph.microsoft.com`
- Azure Resource Manager: `https://management.azure.com/`
- Classic Azure Management: `https://management.core.windows.net/`

---

Everything in this repository is to be used for educational purposes only.

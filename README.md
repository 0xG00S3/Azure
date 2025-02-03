# Azure
Azure Pentesting Resource


---

# Scripts

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

# exfil_exchange_email.py

## Microsoft Graph Email Exfiltrator

A Python script that leverages Microsoft Graph API access tokens to retrieve and save emails from Exchange Online/Microsoft 365 mailboxes. The script demonstrates automated email content extraction using the Microsoft Graph API endpoints.

## Features
- Authenticates using Microsoft Graph API access tokens
- Retrieves email messages from the authenticated user's mailbox
- Extracts email subjects and full message bodies
- Automatically detects and handles HTML-formatted emails
- Saves email content to local files for offline analysis
- Uses Microsoft Graph v1.0 API for stable operation

## Technical Details
- Utilizes the `/me/messages` Graph API endpoint
- Filters response to include subject and body content
- Handles HTML content type detection and preservation
- Implements proper error handling for API responses
- Maintains original HTML formatting for rendered viewing

## Dependencies
- requests
- json
- base64

## Usage
1. Insert a valid Microsoft Graph API access token
2. Run the script to begin email extraction
3. HTML emails are saved with their subjects as filenames

---

Everything in this repository is to be used for educational purposes only.

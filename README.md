# PowerShell Block Domains Script

This PowerShell script uses Microsoft Graph API to block a list of domains in an Azure Active Directory (AAD) B2B Management Policy. It allows the bulk addition of blocked domains and can handle large numbers of domains by splitting the input into multiple files.

## Prerequisites

- PowerShell 7.x or higher
- Microsoft Graph PowerShell SDK (`Connect-MgGraph`)
- An Azure AD tenant with appropriate permissions
- A list of domains to be blocked (in `.txt` format)

## Usage

1. Clone this repository to your local machine.
2. Modify the `$policyId` variable to match your specific policy ID.
3. Update the `$path` variable to the directory where your domain files are stored.
4. Ensure your domain files (e.g., `blocked_domains_part1.txt`, `blocked_domains_part2.txt`) are in the specified directory.
5. Run the script to update the policy and block domains:

```powershell
.\BlockDomains.ps1

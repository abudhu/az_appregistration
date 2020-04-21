
# az_appregistration
Azure Automation Powershell Runbook.  Enumerate all Azure AD Application Registrations, and determine which have less than 2 owners.  Those owners are then notified of all of their Non-Compliant Applications.

> [Requirements](#requirements) |
  [Installation](#installation) |
  [Examples](#examples)

## Requirements
* Azure Subscription
* Azure Automation Account
	* Azure RunAs Account Enabled
* Azure RunBook Account Permissions:
	* To Azure AD
	* To Azure KeyVault (Optional - For Sending Emails)
* Azure Powershell Modules
	* Az.Accounts
	* Az.KeyVault (Optional)
	* Az.Resources
	* Azure
	* AzureAD
* Azure O365 / Azure EventGrid (Optional - For Sending Emails)

## Installation

 1. Access Your Automation Account
 2.  Under **Process Automation** navigate to **Runbooks**
 3. Select **Import a runbook** and import this PS1 file.  Enter a Friendly Name for the Runbook and select **Powershell** as the Runbook Type
 
## Examples

```bash
Name                           Value                                                                                    
----                           -----                                                                                    
user@email.com... {6861f6ba-77a7-410a-855a-411fa0d07009}                                                   
user2@email.co... {2a31c773-b47d-4b57-abc4-7d8c510b5acc, b097e756-ec7c-4d50-98e8-399bd8ea5cfb}
```
 

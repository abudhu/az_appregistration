#################################################
#
# Name:       Application Registration Owner Finder
# Purpose:    Finds all Application Registrations in Azure AD, and then determine which applications have less than 1 owner. 
#             Email the application owner that they need to add an additional backup owner to their application.
# Updated:    04/21/2020
#
#################################################

# Authenticate as the Azure Automation Runbook User

$ConnectionName = 'AzureRunAsConnection'
try
{
    # Get the connection properties
    $ServicePrincipalConnection = Get-AutomationConnection -Name $ConnectionName      

    # Output to Null so it doesn't become part of the output
    $null = Connect-AzureAD `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch 
{
    if (!$ServicePrincipalConnection)
    {
        # You forgot to turn on 'Create Azure Run As account' 
        $ErrorMessage = "Connection $ConnectionName not found."
        throw $ErrorMessage
    }
    else
    {
        # Something else went wrong
        Write-Error -Message $_.Exception.Message
        throw $_.Exception
    }
}

# Create Variables
$application_objectIds = @()
$invalid_applications = @{}
$owner_emails = @()
$final_hash = @{}

# Get the list of Azure Applications
$adapplications = Get-AzureADApplication -All:$True

# Put all the ObjectIds into the Application Object ID array
$application_objectIds += $adapplications.ObjectId

# Interate over the Objects and find the Applications with less than one owner
foreach ($objectID in $application_objectIds) {
    $owners = Get-AzureADApplicationOwner -ObjectId $objectID.ToString()

    if ($owners.Count -lt 2){
        $invalid_applications[$objectID] = $owners.UserPrincipalName
        $owner_emails += $owners.UserPrincipalName
    }
}

# Remove duplicate emails, because that owner is the sole owner of multiple applications
$owner_emails = $owner_emails | select -Unique

# Our Hash is currently in format:
# {"App UID": "Email"}
# This is because the Key must be unique, otherwise our loop above would just overwrite the Value at Key
# So now we take the list of unique email addresses, and find the UID where its value matches the email
# And we store the Email as the Key and the UID as a Value in an array.
# This turns the hash into format:
# {"Email": ["App UID Array"]}

foreach ($email in $owner_emails) {
    $final_hash[$email] = @()

    foreach ($key in ($invalid_applications.GetEnumerator() | Where-Object {$_.Value -eq $email})) {
        $final_hash[$email] += $key.name
    }

}
# Write the hash to Output
$final_hash

# Next Steps:
# Iterate over the final_hash, and foreach Key (which is a unique email address), email User with the Values of the Applications that 
# lack multiple owners.

# Use SendGrid: https://docs.microsoft.com/en-us/azure/automation/automation-send-email
# Use Outlook 365: https://gallery.technet.microsoft.com/scriptcenter/Sending-email-from-Azure-547715b1

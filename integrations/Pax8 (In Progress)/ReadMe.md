# Pax8 PowerShell Integration
This PowerShell module allows you to interact with the Pax8 API to retrieve and manage billing information for subscriptions based on their usage. It includes functions to retrieve company and subscription data from Pax8 and update billing information accordingly using the Synthesize API.

## Prerequisites
1. You need to have PowerShell installed on your system. PowerShell 5.1 or later is recommended.
2. You must have a Pax8 account with the necessary permissions to access the API.

### Install the Pax8API PowerShell Module
You can install the Pax8API PowerShell module directly from the PowerShell Gallery by running the following command:

```powershell
Install-Module -Name Pax8API -RequiredVersion 0.1
```

### Retrieve Client ID and Secret from Pax8
To access the Pax8 API, you need to retrieve your Client ID and Client Secret.

- Log in to the Pax8 Partner Portal with your account credentials. 
- Navigate to the API section or developer portal. 
- Look for your API credentials (Client ID and Client Secret) or create a new API client if necessary. Make sure you have the appropriate permissions for your desired operations. 

## Using the Pax8 PowerShell Integration
Once you have installed the Pax8API PowerShell module and retrieved your API credentials, you can call the functions provided by the module to interact with the Pax8 API.

This module uses the Pax8 PowerShell module to get companies, subscriptions, and create them in the Synthesize API to automatically push usage to Synthesize.

For example, to synchronize usage and billing information for subscriptions, you can call the Invoke-SyncUsage function:

```powershell
Invoke-SyncUsage
```

Please refer to the provided PowerShell scripts for more details on how to use the functions and customize them according to your needs.
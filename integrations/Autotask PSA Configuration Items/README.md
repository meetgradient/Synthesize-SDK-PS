# Autotask PSA Configuration Items Integration Readme
## Overview
This integration allows you to sync counts of configuration items by configuration type quantities by account in Autotask PSA into Synthesize. Specifically, this integration is designed to sync configurations of type "Desktop", "Laptop", "Server" from Autotask PSA, but can be modified to include other configuration item types.

## Getting Started
Before you can use this integration, you need to obtain a public and private key and a client ID from ConnectWise PSA. If you're not familiar with ConnectWise PSA API authentication, you can refer to the ConnectWise PSA Developer Guide for more information.

Before you can use this integration, you need to obtain the following information from ConnectWise PSA:

### Public and Private Keys
To obtain a public and private key, you need to generate a new set of API keys in ConnectWise PSA. To do this, follow these steps:

1. Log in to your ConnectWise PSA account.
2. Click on the menu icon in the top left corner and select "System" from the dropdown menu.
3. Click on "Members" in the left-hand navigation menu.
4. Select an existing member or create a new one.
5. On the Member Maintenance screen, click the "API Keys" tab.
6. Click the "New Item" button.
7. In the "Description" field, enter a description for the API keys (e.g. "Synthesize Integration").
8. Click the "Save" button to create the new keys.
9. The public and private API keys will be generated and displayed in their respective fields.
10. Copy and securely store the private key as it will not be displayed again.

Make sure that the member you selected has all the necessary rights to set up the integration. These steps will allow you to obtain the public and private keys needed for authentication when using this integration.

### API User
An "API User (system)" license type user is required: [API User (system)](https://www.autotask.net/help/DeveloperHelp/Content/APIs/General/Define_API_User.htm)

### Integration Code
To obtain your Integration Code, you need to create an "API User (system)" license type user: [Integration Code](https://www.autotask.net/help/DeveloperHelp/Content/APIs/General/Define_API_User.htm?Highlight=integration%20code#)

## Functions
The script consists of several functions, with the primary ones being:

#### Get-Configurations
This function retrieves configuration objects from the Autotask PSA API, filters the objects based on their configuration items type, and creates a dictionary with the count of configurations per company ID.

#### Invoke-SyncAccounts
This function is a wrapper for the account creation process. It fetches the company details using Get-Companies and then invokes the Invoke-CreateAccounts function, passing the configuration details as a parameter. This function makes it easier to manage and maintain the account creation process.

#### Invoke-SyncUsage
This function syncs the configuration counts fetched from Get-Configuration with your Synthesize data. It does this by iterating through all the sites, adding the count of configurations to the $Summary hashtable, and then creating billing requests that are sent to the Synthesize API to update the unit counts in Synthesize.

### Benefits
By incorporating the configuration items count data from Autotask PSA into your Synthesize resale stack and automating the syncing of usage and account creation, you can ensure that your inventory and billing information is up-to-date and accurate. This reduces manual work and minimizes potential errors in device management and billing.

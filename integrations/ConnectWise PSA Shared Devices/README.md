# ConnectWise Shared Devices Integration Readme
## Overview
This integration allows you to sync shared and not shared device quantities by account in ConnectWise PSA into Synthesize. Specifically, this integration is designed to analyze configurations in ConnectWise PSA, identify shared and not shared devices based on the contact name and assignment type, and sync the corresponding quantities. This integration is tailored to a specific use case, but you can modify the script to adapt it to other scenarios or configuration types.
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

### Client ID
To obtain your client ID, you need to create an account on the ConnectWise developer portal and request a new client ID. You can do this by visiting https://developer.connectwise.com/ClientID and following the instructions provided.

### API URL
The API URL for ConnectWise PSA varies depending on whether you are using a cloud or on-premise environment. For cloud environments, the most commonly used URLs are:

- https://na.myconnectwise.net
- https://eu.myconnectwise.net
- https://au.myconnectwise.net
- https://aus.myconnectwise.net
- https://za.myconnectwise.net
- https://staging.connectwisedev.com

For on-premise environments, the URL will typically contain "v4_6_release/". If your returned codebase contains anything other than "v4_6_release/", you will need to ensure your request is prefixed by "API-".

## Functions
The script consists of several functions, with the primary ones being:

#### Get-ConfigurationDetails
This function retrieves configuration objects from the ConnectWise PSA API, filters the objects based on their "License" type, and creates a dictionary with the count of license configurations per company ID.

#### Invoke-SyncAccounts
This function is a wrapper for the account creation process. It fetches the configuration details using Get-ConfigurationDetails and then invokes the Invoke-CreateAccounts function, passing the configuration details as a parameter. This function makes it easier to manage and maintain the account creation process.

#### Invoke-SyncUsage
This function syncs the configuration counts fetched from Get-ConfigurationDetails with your Synthesize data. It does this by iterating through all the sites, adding the count of configurations to the $Summary hashtable, and then creating billing requests that are sent to the Gradient API to update the unit counts in Synthesize.

### Benefits
By incorporating the configuration count data from ConnectWise PSA into your Synthesize resale stack and automating the syncing of usage and account creation, you can ensure that your inventory and billing information is up-to-date and accurate. This reduces manual work and minimizes potential errors in device management and billing.

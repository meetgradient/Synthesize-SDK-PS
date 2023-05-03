# Synthesize PowerShell SDK
## Introduction
Welcome to the nest of the official PowerShell SDK for Synthesize API!
Our SDK offers full access to Synthesize API, allowing you to seamlessly set up custom integrations to synchronize vendor usage or push alerts to your PSA.
Our intuitive and highly customizable SDK is designed to make coding easy and enjoyable. Whether you're a seasoned developer or just starting out, you can leverage the full capabilities of Synthesize API with ease. Let's get started!

## Disclaimer
Please note that any sample scripts provided in the Gradient MSP documentation are not supported under any Gradient MSP support program or service and are provided on an as-is basis. Gradient MSP disclaims all implied warranties and shall not be liable for damages arising out of the use of or inability to use the sample scripts. It's important to review, test, and understand any scripts you download before implementing them in production.

## Requirements
Before using the Synthesize PowerShell SDK, ensure that you have the following:
- PowerShell 7.0 or later
- Synthesize API credentials
- Vendor API credentials
- Synthesize PowerShell SDK Installation
- Synthesize Account ([Register or Login Here](https://app.usegradient.com/login))

## Step 1: Obtain the Repository
### Option 1: Clone the Repository with Git
Open the PowerShell terminal and navigate to the directory where you want to clone the repository. Run the following command:

```powershell
git clone https://github.com/meetgradient/Synthesize-SDK-PS.git
```

### Option 2: Download the .zip Repository
If you don't have Git installed, you can download the .zip repository from GitHub:

1. Visit https://github.com/meetgradient/Synthesize-SDK-PS
2. Click on the green "Code" button and choose "Download ZIP"
3. Extract the contents of the .zip file to your desired directory

## Step 2: Import Module

After downloading or cloning the Synthesize SDK, you need to import the module before running commands like sync-accounts and others.

To import the module, navigate to the Synthesize-SDK-PS directory in the PowerShell terminal:

```powershell
cd C:\Users\YourUsername\Documents\GitHub\Synthesize-SDK-PS
```

Then, import the module by running the following command:

```powershell
Import-Module .\PSMain.ps1
```

Now you can run the commands like sync-accounts, sync-services, and other commands. For example:

```powershell
pwsh -File "PSMain.ps1" sync-accounts
```


## Getting Started
For a comprehensive, step-by-step guide on implementing integrations with the Synthesize PowerShell SDK, please refer to the README.md file in the Integrations directory.

## Template
There is a Template available to use the SDK which is available in the Template directory of this repository. See 
the README.md file in that directory for more information.

## Support
If you have any questions or issues with the SDK, please contact support@meetgradient.com.

## Related Links
- [Gradient website](https://www.meetgradient.com/)
- [Synthesize Login](https://app.usegradient.com/login)
- [Synthesize API documentation](https://api-docs.meetgradient.com/docs)
- [Synthesize Swagger documentation](https://app.usegradient.com/api-docs)

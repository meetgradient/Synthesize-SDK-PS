# Gradient PowerShell SDK
## Introduction
Welcome to the nest of the official PowerShell SDK for Synthesize API!
Our SDK offers full access to Synthesize API, allowing you to seamlessly set up custom integrations to synchronize vendor usage or push alerts to your PSA.
Our intuitive and highly customizable SDK is designed to make coding easy and enjoyable. Whether you're a seasoned developer or just starting out, you can leverage the full capabilities of Synthesize API with ease. Let's get started!

## Disclaimer
Please note that any sample scripts provided in the Gradient MSP documentation are not supported under any Gradient MSP support program or service and are provided on an as-is basis. Gradient MSP disclaims all implied warranties and shall not be liable for damages arising out of the use of or inability to use the sample scripts. It's important to review, test, and understand any scripts you download before implementing them in production.

## Requirements
Before using the Gradient PowerShell SDK, ensure that you have the following:
- PowerShell 7.0 or later
- Gradient API credentials
- Vendor API credentials
- Gradient PowerShell SDK Installation
- Synthesize Account ([Register or Login Here](https://app.usegradient.com/login))

## Installation
There are two ways to install the Gradient PowerShell SDK:

### 1. Clone Repository
The first method is to clone this repository and place the PSGradient directory in your PowerShell modules directory. Here are the steps to follow:
1. Clone this repository to your local machine using your preferred method (e.g., Git command line, GitHub Desktop, etc.).
2. Navigate to the cloned repository's root directory.
3. Copy the PSGradient directory.
4. Paste the PSGradient directory into your PowerShell modules directory. The default path for this directory is `C:\Program Files\WindowsPowerShell\Modules`.
   Once you have completed these steps, you can import the PSGradient module into your PowerShell session and start using it. Here is an example:
```
Import-Module -Name "PSGradient"
$GRADIENT_TOKEN = BuildGradientToken $Env:VENDOR_API_KEY $Env:PARTNER_API_KEY
#Init SDK
Set-PSConfiguration 'https://app.usegradient.com' '' '' @{
    'Gradient-Token' = $GRADIENT_TOKEN
}
#Call Endpoint
Get-PSIntegration
```
### 2. Import Module
The second method is to import the module as shown in the Template directory. Here are the steps to follow:
1. Download or clone the Template directory from this repository.
2. Open PowerShell and navigate to the Template directory. To download the Template directory from this repository, 
   click the green (code) button to download the entire repository as a single .zip file.
3. Run the command `Import-Module -Name .\PSGradient.psd1` to import the PSGradient module into your PowerShell session.
   Once you have completed these steps, you can start using the PSGradient module in your PowerShell scripts. Here is an example:
```
Import-Module -Name "PSGradient"
$GRADIENT_TOKEN = BuildGradientToken $Env:VENDOR_API_KEY $Env:PARTNER_API_KEY
#Init SDK
Set-PSConfiguration 'https://app.usegradient.com' '' '' @{
    'Gradient-Token' = $GRADIENT_TOKEN
}
#Call Endpoint
Get-PSIntegration
```

## Getting Started
To use the SDK, you will need to have your Gradient API credentials, which consist of Vendor API Key and a Partner 
API key. 
These 
credentials can be obtained from the Gradient web console.

Once you have your credentials, you can use the SDK to interact with the Gradient API. For example, to get your 
Integration, 
you 
can do the following:

```powershell
Import-Module -Name "PATH-TO-SDK"
$GRADIENT_TOKEN = BuildGradientToken $Env:VENDOR_API_KEY $Env:PARTNER_API_KEY

#Init SDK
Set-PSConfiguration 'https://app.usegradient.com' '' '' @{
    'Gradient-Token' = $GRADIENT_TOKEN
}
#Call Endpoint
Get-PSIntegration
```

## Pre-Build Integrations
There are multiple integrations available to use the SDK, which is located in the Integrations directory of this repository. For more information, see the README.md file in that directory.

## Template
There is a Template available to use the SDK which is available in the Template directory of this repository. See 
the README.md 
file in that directory for more information.

## Support
If you have any questions or issues with the SDK, please contact support@usegradient.com.

## Related Links
- [Gradient website](https://www.meetgradient.com/)
- [Synthesize Login](https://app.usegradient.com/login)
- [Synthesize API documentation](https://api-docs.meetgradient.com/docs)
- [Synthesize Swagger documentation](https://app.usegradient.com/api-docs)
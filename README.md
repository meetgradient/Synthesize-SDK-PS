# Gradient PowerShell SDK
This is the official PowerShell SDK for the Gradient API. This SDK is generated from the Swagger documentation for 
the Gradient API.

## Requirements
- PowerShell 7.0 or later
- Gradient API credentials

## Installation
To install the SDK, you can clone this repository and place the PSGradient directory in your PowerShell modules 
directory. Alternatively, you can import the module as shown in the template directory.

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


## Template
There is a Template available to use the SDK which is available in the Template directory of this repository. See 
the README.md 
file in that directory for more information.

## Support
If you have any questions or issues with the SDK, please contact support@usegradient.com.

## Related Links
* https://www.meetgradient.com
* https://app.usegradient.com/api-docs
* https://api-docs.meetgradient.com/docs
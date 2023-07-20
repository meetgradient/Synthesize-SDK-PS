# GradientMSP PowerShell SDK Template
This is a PowerShell template project that demonstrates how to use the GradientMSP SDK to build Custom 
Integrations with PowerShell. The 
template contains sample code that demonstrates how to connect to a vendor using the SDK and perform basic operations.

## Requirements
- PowerShell 7.0 or later
- API access for the vendor you want to interact with
- API keys for GradientMSP

## Installation
- Clone this repository to your local machine using Git
- Copy `sample.env` and rename the file to `.env`
- Obtain the API keys for the SDK, and add them to the ENV file
- Obtain the API keys or credentials for the Vendor API
- Validate that the variable `$SdkDir` is referencing the correct path for the Gradient SDK within `PSImports.
  ps1` 

## Implementing the Template
The following functions are available in this template(found in `PSCustomIntegrations.ps1`):
- Invoke-AuthenticateVendorAPI
  - Authentication to the Vendor API should be handled here. This is called from `PSMain.ps1` with the 
    `authenticate` argument
  - HINT: Seeing some duplicated code? Creating a wrapper for the Vendor API Endpoints could save you some time, and 
    help with debugging!
- Get-AllAccountsFromVendor
  - Collects all accounts from the vendor that should be synced to Gradient MSP. This is called from 
    `PSCreateAccountsFromVendor` from `PSMain` with the argument `sync-accounts`
  - `PSCreateAccountsFromVendor` expects the response from `Get-AllAccountsFromVendor` to be an array of objects 
    which have an `id` and `name` field
  - The helper function `Invoke-CreateAccounts` (from GradientSDK) will check GradientMSP for duplicate accounts and 
    create new ones as needed
- Get-AllServicesFromVendor
  - Collects all services from the vendor that should be synced to Gradient MSP. This is called from 
    `PSCreateServicesFromVendor` from `PSMain` with the argument `sync-services`.
  - `PSCreateServicesFromVendor` expects the response from `Get-AllServicesFromVendor` to be an array of objects 
    which have a `Name`, `Description`, `Category`, and `SubCategory` key/value pairs.
    - `Category` and `SubCategory` options can be found within the `ServiceCategoryEnum` and 
      `ServiceSubCategoryEnum` models
- Get-AccountUsage
  - The meat and potatoes! This is where we can collect the actual usage for each Service for each Account, and then 
    send it to GradientMSP
  - This is called from `PSSyncUsage` which has some boilerplate code as an example
  
## Usage
- Open a PowerShell console or the PowerShell ISE.
- Navigate to the project directory.
- Run the PSMain.ps1 script with one of the following arguments:
  - `authenticate`
  - `sync-accounts`
  - `sync-services`
  - `sync-usage`
  - `update-status`
- The script will use the SDK to connect to the service and perform the specified operations.

## Sample Responses
#### Token
```
{
    "access_token": "<TOKEN>",
    "token_type": "bearer",
    "refresh_token": "<REFRESH TOKEN>",
    "mfa_token": null,
    "encrypted_code": null,
    "expires_in": 3600
}
```
#### Companies
```
{
    "data": [
        {
            "name": "FooBar",
            "instanceUid": "<UID>",
            "status": "Active"
        },
    ],
    "meta": {
        "pagingInfo": {
            "total": 1,
            "count": 0,
            "offset": 0
        }
    }
}
```
#### Services/Usage
```
{
    "meta": {
        "pagingInfo": {
            "total": 1,
            "count": 0,
            "offset": 0
        }
    },
    "data": [
        {
            "companyUid": "<Company.instanceUid>",
            "resellerUid": null,
            "locationUid": "<Location.Uid>",
            "date": "2023-05-17T00:00:00.0000000+00:00",
            "counters": [
                {
                    "value": 0,
                    "type": "VmCloudBackups"
                },
                {
                    "value": 0,
                    "type": "ServerCloudBackups"
                },
            ]
        }
    ]
}
```

## Examples
Within the Integrations Directory there are many examples of our integrations making use of this template! Feel free 
to use them as a reference.

## Related Links

* https://www.meetgradient.com
* https://app.usegradient.com/api-docs
* https://api-docs.meetgradient.com/docs

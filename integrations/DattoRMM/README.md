1. Copy sample env, add env vars
2. Add validation for ENV vars
3. PSCustomIntegrations -> Complete Invoke-VendorAPI
   4. This is where custom authentication, headers required for requests, or pagination can be added.
5. PSCustomIntegrations -> Complete AuthenticateVendorAPI
   6. Implement to test authentication for vendor API
   7. Should useInvoke-VendorAPI to complete the request
   8. Once implemented, can test by running `pwsh -File "PSMain.ps1" authenticate`
9. PSCustomIntegrations -> Complete GetVendorAccounts
   10. This should get all the accounts in the vendor, format them, and then return them
   11. Can be tested by running `pwsh -File "PSMain.ps1" sync-accounts`
9. PSCustomIntegrations -> Complete GetVendorServices
   10. This should get all the services for the vendor. Right now we are just wanting the name of the service, and 
       then within `PSCreateServicesFromVendor` the description, support URL and contact can be updated.
   11. Can be tested by running `pwsh -File "PSMain.ps1" sync-services` 
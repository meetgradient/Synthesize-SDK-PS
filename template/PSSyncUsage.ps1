Function Invoke-SyncUsage {
    Param(
    ) Process {
        try {
            Write-Host "Starting call"
            $VendorAccounts = Get-AllAccountsFromVendor
            $ServiceIds = Invoke-GetServiceMappingIds #Service IDs created in GradientMSP to associate to the correct Vendor Service
            foreach ($site in $VendorAccounts.GetEnumerator()) {
                #Get Active Licenses
                $UsageCount = Get-AccountUsage $site.Value.id
                Write-Host 'Loop through summary'
                if($UsageCount.Value -gt 0) {
                    #Create the DTO
                    $body = Initialize-PSCreateBillingRequest  $null $site.Value.id $service.Value
                    #If OID of account is not known, exclude the property
                    $body = $body | Select-Object -Property * -ExcludeProperty clientOId
                    #Talk to Gradient API to post request
                    $response = New-PSBilling $ServiceIds["Vendor Service Name"] $body
                }
            }
        } catch {
            Write-Error $_
            throw 'An error occurred while syncing usage. Script execution stopped.'
        }
    }
}

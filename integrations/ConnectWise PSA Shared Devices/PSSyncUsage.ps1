Function Invoke-SyncUsage {
    Param() Process {
        try {
            $configDetails = Get-ConfigurationDetails
            $Sites = Invoke-GetAccountSites
            $loop = 0
            $ServiceIds = Invoke-GetServiceIds
            $VendorServices = GetVendorServices

            foreach ($Site in $Sites.GetEnumerator()) {
                Write-Host $Site.Value.id $Site.Value.name
                $Summary = @{}

                $siteConfigDetail = $configDetails | Where-Object { $_.id -eq $Site.Value.id }
                $Summary["Shared Devices"] = $siteConfigDetail.sharedcounts
                $Summary["Not Shared Devices"] = $siteConfigDetail.notsharedcounts

                foreach ($service in $Summary.GetEnumerator()) {
                    if ($service.Value -gt 0) {
                        $body = Initialize-PSCreateBillingRequest $null $Site.Value.id $service.Value
                        $body = $body | Select-Object -Property * -ExcludeProperty clientOId

                        Write-Host $body
                        try {
                            # Talk to Gradient API to post request
                            $serviceId = ($VendorServices | Where-Object { $_.Name -eq $service.Key }).Name
                            Write-Host $ServiceIds
                            Write-Host $ServiceIds[$serviceId]
                            $response = New-PSBilling $ServiceIds[$serviceId] $body
                        }
                        catch {
                            Write-Host "Failed to update unit count for Site ID: $($Site.Value.id), SKU: $($ServiceIds[$service.Key]), Unit Counts: $($service.Value). Error message: $($_)" -ForegroundColor Red
                        }
                    }
                }
                $loop++
            }
        } catch {
            Write-Error $_
            throw 'An error occurred while syncing usage. Script execution stopped.'
        }
    }
}

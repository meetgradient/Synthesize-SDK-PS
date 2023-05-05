Function Invoke-SyncUsage {
    Param(
    )
    Process {
        try {
            $loop = 0
            $ServiceIds = Invoke-GetServiceIds
            # Get the usage information
            $usageInfo = Get-Usage
            $companies = $usageInfo["companies"]
            $subscriptionDetails = $usageInfo["subscriptionDetails"]

            foreach ($company in $companies.Values) {
                Write-Host "Processing Company: $($company.name) - $($company.id)"
                $companySubscriptions = $subscriptionDetails | Where-Object { $_.customerId -eq $company.id }
                foreach ($subscription in $companySubscriptions) {
                    Write-Host $subscription.customerId $subscription.productName
                    $Summary = @{
                        $($subscription.productName) = $subscription.quantity
                    }
                    $loop++

                    Write-Host 'Loop through summary'
                    foreach ($service in $Summary.GetEnumerator()) {
                        if ($service.Value -gt 0)
                        {
                            # Initialize your billing request object based on your specific implementation
                            $body = Initialize-PSCreateBillingRequest $null $subscription.customerId $service.Value
                            $body = $body | Select-Object -Property * -ExcludeProperty clientOId

                            Write-Host $body
                            try
                            {
                                #Talk to Gradient API to post request
                                Write-Host 'Sending for client'
                                Write-Host $ServiceIds
                                Write-Host $ServiceIds[$Service.Key]
                                $response = New-PSBilling $ServiceIds[$Service.Key] $body
                            }
                            catch {
                                Write-Host "Failed to update unit count for Customer ID: $( $subscription.customerId ), SKU: $( $subscription.sku ), Unit Counts: $( $service.Value ). Error message: $( $_ )" -ForegroundColor Red
                            }
                        }
                    }
                }
            }
        } catch {
            Write-Error $_
            throw 'An error occurred while syncing usage. Script execution stopped.'
        }
    }
}
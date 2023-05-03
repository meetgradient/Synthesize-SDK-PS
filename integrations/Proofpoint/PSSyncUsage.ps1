Function Invoke-SyncUsage {
    Param(
    )
    Process {
        try {
            $loop = 0
            $ServiceIds = Invoke-GetServiceIds
            # Get the licensing information
            $licensingData = Invoke-ProofpointLicensing
            $uniqueLicensingPackages = Get-VendorServices

            foreach ($item in $licensingData) {
                Write-Host "Processing Company: $($item.name) - $($item.id)"
                $licensingPackageName = $item.'licensing_package'
                $quantity = $item.quantity

                if (-not [string]::IsNullOrEmpty($licensingPackageName)) {
                    Write-Host $item.id $licensingPackageName

                    $Summary = @{
                        $($licensingPackageName) = $quantity
                    }
                    $loop++

                    Write-Host 'Loop through summary'
                    foreach ($service in $Summary.GetEnumerator()) {
                        if ($service.Value -gt 0)
                        {
                            # Initialize your billing request object based on your specific implementation
                            $body = Initialize-PSCreateBillingRequest $null $item.id $service.Value
                            $body = $body | Select-Object -Property * -ExcludeProperty clientOId

                            Write-Host $body
                            try
                            {
                                #Talk to Gradient API to post request
                                Write-Host 'Sending for client'
                                Write-Host $ServiceIds
                                Write-Host $ServiceIds[$service.Key]
                                $response = New-PSBilling $ServiceIds[$service.Key] $body
                            }
                            catch {
                                Write-Host "Failed to update unit count for Customer ID: $( $item.id ), Licensing Package: $( $licensingPackageName ), Unit Counts: $( $service.Value ). Error message: $( $_ )" -ForegroundColor Red
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

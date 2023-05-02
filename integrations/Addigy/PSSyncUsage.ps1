Function Invoke-SyncUsage {
    Param() Process {
        try {
            $PolicyDeviceCounts = Get-PolicyDeviceCount
            if ($null -eq $PolicyDeviceCounts) {
                Write-Error "Get-PolicyDeviceCount returned null"
                return
            }
            $loop = 0
            $ServiceIds = Invoke-GetServiceIds
            Write-Host "ServiceIds: $ServiceIds"
            foreach ($PolicyDeviceCount in $PolicyDeviceCounts.GetEnumerator()) {
                Write-Host "Policy ID: $($PolicyDeviceCount.Value.id) Name: $($PolicyDeviceCount.Value.name)"
                $Summary = @{
                    "Total Devices" = $PolicyDeviceCount.Value.quantity
                }

                foreach ($service in $Summary.GetEnumerator()) {
                    if ($service.Value -gt 0) {
                        $body = Initialize-PSCreateBillingRequest $null $PolicyDeviceCount.Value.id $service.Value
                        $body = $body | Select-Object -Property * -ExcludeProperty clientOId

                        Write-Host $body
                        try {
                            # Talk to Gradient API to post request
                            Write-Host "ServiceIds: $ServiceIds"
                            Write-Host "ServiceKey: $($service.Key)"
                            Write-Host "ServiceId: $($ServiceIds[$service.Key])"
                            $response = New-PSBilling $ServiceIds[$service.Key] $body
                        }
                        catch {
                            Write-Host "Failed to update device count for Policy ID: $($PolicyDeviceCount.Value.id), SKU: $($ServiceIds[$service.Key]), Device Counts: $($service.Value). Error message: $($_)" -ForegroundColor Red
                        }
                    }
                }
                $loop++
            }
        } catch {
            Write-Error $_
            throw 'An error occurred while syncing device usage. Script execution stopped.'
        }
    }
}

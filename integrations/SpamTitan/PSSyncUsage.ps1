Function Invoke-SyncUsage {
    Param() Process {
        try {
            $Organizations = Get-SpamTitanDetails
            $loop = 0
            $ServiceIds = Invoke-GetServiceIds
            foreach ($Organization in $Organizations.GetEnumerator()) {
                Write-Host $Organization.Value.id $Organization.Value.name
                $Summary = @{}

                $licenseCount = $Organization.Value.maximum

                $Summary["Total Licenses"] = $licenseCount

                foreach ($service in $Summary.GetEnumerator()) {
                    if ($service.Value -gt 0) {
                        $body = Initialize-PSCreateBillingRequest $null $Organization.Value.id $service.Value
                        $body = $body | Select-Object -Property * -ExcludeProperty clientOId

                        Write-Host $body
                        try {
                            # Talk to Gradient API to post request
                            Write-Host $ServiceIds
                            Write-Host $ServiceIds[$service.Key]
                            $response = New-PSBilling $ServiceIds[$service.Key] $body
                        }
                        catch {
                            Write-Host "Failed to update unit count for Organization ID: $($Organization.Value.id), SKU: $($ServiceIds[$service.Key]), Unit Counts: $($service.Value). Error message: $($_)" -ForegroundColor Red
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
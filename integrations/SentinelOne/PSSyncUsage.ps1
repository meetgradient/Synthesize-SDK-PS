Function Invoke-SyncUsage {
    Param() Process {
        try {
            $Sites = Invoke-GetAccountSites
            $loop = 0
            $ServiceIds = Invoke-GetServiceIds
            foreach ($Site in $Sites.GetEnumerator()) {
                Write-Host $Site.Value.id $Site.Value.name
                $Summary = @{}

                $sku = $Site.Value.sku
                $activeLicenses = $Site.Value.activelicenses

                if ($sku -eq "Singularity Core") {
                    $Summary["Total active licenses for Singularity Core"] = $activeLicenses
                }
                elseif ($sku -eq "Singularity Control") {
                    $Summary["Total active licenses for Singularity Control"] = $activeLicenses
                }
                elseif ($sku -eq "Singularity Complete") {
                    $Summary["Total active licenses for Singularity Complete"] = $activeLicenses
                }
                $Summary["Total Active Licenses"] = $activeLicenses

                foreach ($service in $Summary.GetEnumerator()) {
                    if ($service.Value -gt 0) {
                        $body = Initialize-PSCreateBillingRequest $null $Site.Value.id $service.Value
                        $body = $body | Select-Object -Property * -ExcludeProperty clientOId

                        Write-Host $body
                        try {
                            # Talk to Gradient API to post request
                            Write-Host $ServiceIds
                            Write-Host $ServiceIds[$service.Key]
                            $response = New-PSBilling $ServiceIds[$service.Key] $body
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

Function Invoke-SyncUsage {
    Param() Process {
        try {
            $SiteDictionary = Get-WebrootDetails
            $loop = 0
            $ServiceIds = Invoke-GetServiceIds

            foreach ($Site in $SiteDictionary.Values) {

                $Summary = @{}

                if ($Site.TotalEndpoints) {
                    $Summary["Endpoint Protection"] = $Site.TotalEndpoints
                }
                if ($Site.TotalDNSPAgents) {
                    $Summary["DNS Protection"] = $Site.TotalDNSPAgents
                }
                if ($Site.TotalWSATUsers) {
                    $Summary["WSAT Webroot Security Awareness Training"] = $Site.TotalWSATUsers
                }

                foreach ($service in $Summary.GetEnumerator()) {
                    if ($service.Value -gt 0) {
                        $body = Initialize-PSCreateBillingRequest $null $Site.id $service.Value
                        $body = $body | Select-Object -Property * -ExcludeProperty clientOId

                        Write-Host $body
                        try {
                            # Talk to Gradient API to post request
                            Write-Host $ServiceIds
                            Write-Host $ServiceIds[$service.Key]
                            $response = New-PSBilling $ServiceIds[$service.Key] $body
                        }
                        catch {
                            Write-Host "Failed to update unit count for Site ID: $($Site.id), SKU: $($ServiceIds[$service.Key]), Unit Counts: $($service.Value). Error message: $($_)" -ForegroundColor Red
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

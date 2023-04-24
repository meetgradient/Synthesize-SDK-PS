Function Invoke-SyncUsage {
    Param(
    ) Process {
        try {
            Write-Host "Starting call"
            $deviceSummary = @()
            $VendorAccounts =  GetVendorAccounts
            $loop = 0
            $ServiceIds = Invoke-GetServiceIds
            foreach ($site in $VendorAccounts.GetEnumerator()) {
                Write-Host $site.Value.id $site.Value.name
                $Summary = @{}
                $loop++
                #Get Active Licenses
                $siteDevices = Invoke-GetSiteDevices $site.Value.id
                $desktopCount = ($siteDevices | Where-Object { $_.deviceType.category -eq 'Desktop' }).count
                $laptopCount = ($siteDevices | Where-Object { $_.deviceType.category -eq 'Laptop' }).count
                $serverCount = ($siteDevices | Where-Object { $_.deviceType.category -eq 'Server' }).count
                $totalWorkstations = $desktopCount + $laptopCount
                $totalDevices = $desktopCount + $laptopCount + $serverCount

                Write-Host 'Setting Summary'
                $Summary['Total Devices'] = $totalDevices
                $Summary['Desktops'] = $desktopCount
                $Summary['Laptops'] = $laptopCount
                $Summary['Servers'] = $serverCount
                $Summary['Total Workstations'] = $totalWorkstations
                Write-Host 'Loop through summary'
                foreach ($service in $Summary.GetEnumerator()) {
                    if($service.Value -gt 0)
                    {
                        $body = Initialize-PSCreateBillingRequest  $null $site.Value.id $service.Value
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
                        catch
                        {
                            Write-Host "Failed to update unit count for Site ID: $( $site.Value.id ), SKU: $( $ServiceIds[$Service.Key] ), Unit Counts: $( $service.Value ). Error message: $( $_ )" -ForegroundColor Red
                        }
                    }
                }
            }
            Write-Host $deviceSummary
        } catch {
            Write-Error $_
            throw 'An error occurred while syncing usage. Script execution stopped.'
        }
    }
}

Function Invoke-SyncUsage {
    Param()

    Process {
        try {
            $VendorAccounts = Get-Companies
            $ServiceIds = Invoke-GetServiceIds
            $configurations = Get-Configurations

            foreach ($site in $VendorAccounts.GetEnumerator()) {

                $siteConfigurations = $configurations | Where-Object { $_.CompanyId -eq $site.Value.id }

                $laptopCount = 0
                $desktopCount = 0
                $serverCount = 0
                $networkDeviceCount = 0

                foreach ($config in $siteConfigurations) {
                    switch ($config['Type']) {
                        'Laptop' { $laptopCount++ }
                        'Desktop' { $desktopCount++ }
                        'Server' { $serverCount++ }
                        # Further types can be added if needed
                    }
                }

                $managedWorkstationsCount = $desktopCount + $laptopCount

                # Calculate Network Device Count excluding specified types
                $excludedTypes = @("Desktop", "Laptop", "Server", "ESXi Host")

                # Using the corrected logic here:
                $networkDevices = $siteConfigurations | Where-Object { $_.Type -notin $excludedTypes }
                $networkDeviceCount = $networkDevices.Count

                # Create a summary
                $Summary = @{
                    'Managed Workstations' = $managedWorkstationsCount
                    'Managed Servers' = $serverCount
                    'Network Devices' = $networkDeviceCount
                }

                Write-Host "Summary for $($site.Value.name): $($Summary | Out-String)"

                # Loop through the summary and update usage
                foreach ($service in $Summary.GetEnumerator()) {
                    $serviceName = $service.Key
                    $count = $service.Value

                    if ($count -gt 0) {
                        $ServiceId = $ServiceIds[$serviceName]
                        $body = Initialize-PSCreateBillingRequest $null $site.Value.id $count
                        $body = $body | Select-Object -Property * -ExcludeProperty clientOId

                        Write-Host "Sending for $serviceName"
                        Write-Host $body
                        Write-Host "ServiceId: $ServiceId, Body: $($body | Out-String)"

                        try {
                            $response = New-PSBilling $ServiceId $body
                        } catch {
                            Write-Host "Failed to update unit count for Site ID: $($site.Value.id), Service: $serviceName, Unit Counts: $count. Error message: $_" -ForegroundColor Red
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

Function Invoke-SyncUsage {
    Param(
    )
    Process {
        try {
            Write-Host "Starting call"
            $deviceSummary = @()
            $loop = 0
            $ServiceIds = Invoke-GetServiceIds

            # Get the Auvik Tenants
            $tenants = Get-AuvikTenants

            foreach ($site in $tenants.GetEnumerator()) {
                Write-Host $site.Value.id $site.Value.name
                $Summary = @{}
                $loop++

                # Get device details for each tenant
                $deviceCounts = Get-AuvikDeviceDetails -TenantId $site.Value.id

                # Calculate Total Billable Devices and Switches
                $TotalBillableDevices = $deviceCounts['Firewalls'] + $deviceCounts['Switches'] + $deviceCounts['Controllers'] + $deviceCounts['Routers']
                $AllSwitches = $deviceCounts['Switches'] + $deviceCounts['Layer 3 Switches'] + $deviceCounts['VoIP Switches'] + $deviceCounts['Switch Stacks']

                Write-Host 'Setting Summary'
                $Summary['Total Billable Devices'] = $TotalBillableDevices
                $Summary['Firewalls'] = $deviceCounts['Firewalls']
                $Summary['Total Switches'] = $AllSwitches
                $Summary['Controllers'] = $deviceCounts['Controllers']
                $Summary['Layer 3 Switches'] = $deviceCounts['Layer 3 Switches']
                $Summary['VoIP Switches'] = $deviceCounts['VoIP Switches']
                $Summary['Switch Stacks'] = $deviceCounts['Switch Stacks']
                $Summary['Routers'] = $deviceCounts['Routers']

                Write-Host 'Loop through summary'
                foreach ($service in $Summary.GetEnumerator()) {
                    if ($service.Value -gt 0) {
                        $body = Initialize-PSCreateBillingRequest $null $site.Value.id $service.Value
                        $body = $body | Select-Object -Property * -ExcludeProperty clientOId

                        Write-Host $body
                        try {
                            # Talk to Gradient API to post request
                            Write-Host 'Sending for client'
                            Write-Host $ServiceIds
                            Write-Host $ServiceIds[$Service.Key]
                            $response = New-PSBilling $ServiceIds[$Service.Key] $body
                        } catch {
                            Write-Host "Failed to update unit count for Tenant ID: $( $site.Value.id ), SKU: $( $ServiceIds[$Service.Key] ), Unit Counts: $( $service.Value ). Error message: $( $_ )" -ForegroundColor Red
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

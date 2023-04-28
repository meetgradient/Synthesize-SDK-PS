#The function aggregates device counts based on their node class for each vendor account, creates a billing request for each non-zero service count, and sends the request to the Synthesize API.
#To add or modify a service, you will need to modify the services array returned by GetVendorServices. Note that this function aggregates device counts based on NodeClass. For a full list of Node Roles, please refer to the documentation at the following URL: https://app.ninjarmm.com/apidocs-beta/core-resources/operations/getNodeRoles.

Function Invoke-SyncUsage {
    Param(
    ) Process {
        try {
            Write-Host "Starting call"
            $deviceSummary = @()
            $VendorAccounts =  Get-Organizations
            $loop = 0
            $ServiceIds = Invoke-GetServiceIds
            $Devices = Get-Devices
            foreach ($site in $VendorAccounts.GetEnumerator()) {
                Write-Host $site.Value.id $site.Value.name
                $Summary = @{}
                $loop++
                #Get Active Licenses
                $siteDevices = $Devices | Where-Object { $_.organizationId -eq $site.Value.id -and $_.offline -eq $false }
                $totalWorkstations = ($siteDevices | Where-Object { $_.offline -eq $false -and $_.nodeClass -match 'Workstation|Computer|MAC' }).count
                $serverCount = ($siteDevices | Where-Object { $_.offline -eq $false -and $_.nodeClass -match 'Server|VM|VMM|NMS_VIRTUAL_MACHINE' }).count
                $networkDeviceCount = ($siteDevices | Where-Object { $_.offline -eq $false -and $_.nodeClass -match 'NMS_FIREWALL|NMS_ROUTER|NMS_SWITCH|NMS_WAP' }).count
                $totalDevices = $totalWorkstations + $serverCount + $networkDeviceCount

                Write-Host 'Setting Summary'
                $Summary['Total Devices'] = $totalDevices
                $Summary['Total Servers'] = $serverCount
                $Summary['Total Workstations'] = $totalWorkstations
                $Summary['Total Network Devices'] = $networkDeviceCount
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

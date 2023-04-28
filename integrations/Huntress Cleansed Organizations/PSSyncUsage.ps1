#The function retrieves a report of organizations and their corresponding agent counts using the "Get-OrganizationsReport" function.
#It retrieves a list of service IDs from the Synthesize platform using the "Invoke-GetServiceIds" function.
#For each organization in the report, the function calculates the total number of agents, workstations, and servers using the data from the report.
#It creates a billing request for each service type that has a count greater than zero and sends the request to the Synthesize API using the "New-PSBilling" function.

Function Invoke-SyncUsage {
    Param()

    Process {
        try {
            $OrgData = Get-OrganizationsReport
            $loop = 0
            $ServiceIds = Invoke-GetServiceIds

            foreach ($orgUniqueId in $OrgData.Keys) {
                $Organization = $OrgData[$orgUniqueId]

                Write-Host $Organization.id $Organization.name

                $Summary = @{
                    'Total Agents'  = $Organization.'Total Agents'
                    'Workstations'  = $Organization.Workstations
                    'Servers'       = $Organization.Servers
                }

                foreach ($service in $Summary.GetEnumerator()) {
                    if ($service.Value -gt 0) {
                        $body = Initialize-PSCreateBillingRequest $null $Organization.id $service.Value
                        $body = $body | Select-Object -Property * -ExcludeProperty clientOId

                        Write-Host $body

                        try {
                            # Talk to Gradient API to post request
                            Write-Host $ServiceIds
                            Write-Host $ServiceIds[$service.Key]
                            $response = New-PSBilling $ServiceIds[$service.Key] $body
                        } catch {
                            Write-Host "Failed to update unit count for Organization ID: $($Organization.id), SKU: $($ServiceIds[$service.Key]), Unit Counts: $($service.Value). Error message: $($_)" -ForegroundColor Red
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

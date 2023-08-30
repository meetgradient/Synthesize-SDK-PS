Function Invoke-SyncUsage {
    Param()

    Process {
        try {
            $VendorCompanies = Get-Companies
            $ServiceIds = Invoke-GetServiceIds
            $contacts = Get-Contacts

            foreach ($company in $VendorCompanies.GetEnumerator()) {

                # Get user-defined fields for this company
                $companyContacts = $contacts[$company.Value.id]

                $userDefinedFieldsCounts = @{}

                foreach ($field in $companyContacts) {
                    if (![string]::IsNullOrWhiteSpace($field['value'])) {
                        if ($userDefinedFieldsCounts.ContainsKey($field['value'])) {
                            $userDefinedFieldsCounts[$field['value']]++
                        } else {
                            $userDefinedFieldsCounts[$field['value']] = 1
                        }
                    }
                }

                Write-Host "Summary for $($company.Value.name): $($userDefinedFieldsCounts | Out-String)"

                # Loop through the counts and update usage
                foreach ($service in $userDefinedFieldsCounts.GetEnumerator()) {
                    $serviceName = $service.Key
                    $count = $service.Value

                    if ($count -gt 0) {
                        $ServiceId = $ServiceIds[$serviceName]
                        $body = Initialize-PSCreateBillingRequest $null $company.Value.id $count
                        $body = $body | Select-Object -Property * -ExcludeProperty clientOId

                        Write-Host "Sending for $serviceName"
                        Write-Host $body
                        Write-Host "ServiceId: $ServiceId, Body: $($body | Out-String)"

                        try {
                            $response = New-PSBilling $ServiceId $body
                        } catch {
                            Write-Host "Failed to update unit count for Company ID: $($company.Value.id), Service: $serviceName, Unit Counts: $count. Error message: $_" -ForegroundColor Red
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

Function Invoke-SyncUsage {
    Param()

    Process {
        try {
            $contactDetails = Get-ContactDetails
            Write-Host "Contact Details:"
            $contactDetails | Format-Table -AutoSize
            $ServiceIds = Invoke-GetServiceIds
            Write-Host "Service Ids:"
            $ServiceIds | Format-Table -AutoSize

            foreach ($Site in $contactDetails.GetEnumerator()) {
                Write-Host $Site.Value.id $Site.Value.name
                $Summary = @{
                    'Billed User' = 0
                }

                $siteContactDetail = $contactDetails[$Site.Key]

                foreach ($contact in $siteContactDetail.contactTypes.GetEnumerator()) {
                    if ($contact.Key -eq 'Billed User') { $Summary['Billed User'] += $contact.Value }
                }

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
            }
        } catch {
            Write-Error $_
            throw 'An error occurred while syncing usage. Script execution stopped.'
        }
    }
}

Function Invoke-SyncUsage {
    Param()

    Process {
        try {
            $KnowBe4Groups = Get-KnowBe4Groups
            if ($null -eq $KnowBe4Groups) {
                Write-Error "Get-KnowBe4Groups returned null"
                return
            }
            $loop = 0
            $ServiceIds = Invoke-GetServiceIds
            if ($null -eq $ServiceIds -or $ServiceIds.Count -eq 0) {
                Write-Error "Invoke-GetServiceIds returned null or an empty hashtable"
                return
            }
            Write-Host "ServiceIds: $ServiceIds"

            foreach ($Group in $KnowBe4Groups.GetEnumerator()) {
                Write-Host "Group ID: $($Group.Value.id) Name: $($Group.Value.name)"
                $Summary = @{
                    "Security Awareness Training" = $Group.Value.quantity
                }

                foreach ($service in $Summary.GetEnumerator()) {
                    Write-Host "Processing service: $($service.Key) with quantity: $($service.Value)"
                    if ($service.Value -gt 0) {
                        $body = Initialize-PSCreateBillingRequest $null $Group.Value.id $service.Value
                        $body = $body | Select-Object -Property * -ExcludeProperty clientOId

                        Write-Host "Request Body: $body"
                        try {
                            # Talk to Gradient API to post request
                            Write-Host "ServiceIds: $ServiceIds"
                            Write-Host "ServiceKey: $($service.Key)"
                            Write-Host "ServiceId: $($ServiceIds[$service.Key])"
                            $response = New-PSBilling $ServiceIds[$service.Key] $body
                            Write-Host "API Response: $response"
                        }
                        catch {
                            Write-Host "Failed to update quantity for Group ID: $($Group.Value.id), SKU: $($ServiceIds[$service.Key]), Quantity: $($service.Value). Error message: $($_)" -ForegroundColor Red
                        }
                    }
                }
                $loop++
            }
        } catch {
            Write-Error $_
            throw 'An error occurred while syncing quantity. Script execution stopped.'
        }
    }
}

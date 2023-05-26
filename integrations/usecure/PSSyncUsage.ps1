Function Invoke-SyncUsage {
    Param(
    ) Process {
        try {
            Write-Host 'Starting call'
            $VendorAccounts = Get-usecureClients
            $ServiceIds = Invoke-GetServiceIds #Service IDs created in GradientMSP to associate to the correct Vendor Service
            foreach ($Client in $VendorAccounts.GetEnumerator()) {
                # Get the plan for the client
                Write-Host "Getting usage for $($Client.Value.name) [$($Client.Value.id)]"
                $UsageCount = Get-usecureUsage -accountId $Client.Value.id
                if ($UsageCount.learnerCount -gt 0) {
                    # Create the DTO
                    $Body = Initialize-PSCreateBillingRequest $null $Client.Value.id $UsageCount.learnerCount
                    $Body = $Body | Select-Object -Property * -ExcludeProperty clientOId
                    # Talk to Gradient API to post request
                    $Response = New-PSBilling $ServiceIds[$UsageCount.name] $Body
                }
            }
        } catch {
            Write-Error $_
            throw 'An error occurred while syncing usage. Script execution stopped.'
        }
    }
}

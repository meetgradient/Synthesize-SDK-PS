Function Invoke-SyncUsage {
    Param(
    ) Process {
        try {
            Write-Host "Starting call"
            $ServiceIds = Invoke-GetServiceIds #Service IDs created in GradientMSP to associate to the correct Vendor Service
            $UsageCount = Get-AccountUsage
            foreach ($Usage in $UsageCount.GetEnumerator()) {
                if($Usage.count -gt 0) {
                    try {
                        #Create the DTO
                        $body = Initialize-PSCreateBillingRequest  $null $Usage.accountId $Usage.count
                        #If OID of account is not known, exclude the property
                        $body = $body | Select-Object -Property * -ExcludeProperty clientOId
                        #Talk to Gradient API to post request
                        New-PSBilling $ServiceIds[$Usage.serviceName] $body
                    } catch {
                        Write-Error $_
                    }

                }
            }
        } catch {
            Write-Error $_
            throw 'An error occurred while syncing usage. Script execution stopped.'
        }
    }
}

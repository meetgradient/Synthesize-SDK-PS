function Invoke-CreateAccounts {
    param(
        $VendorAccounts
    )
    try
    {
        $CreatedAccounts = 0
        $GradientAccounts = Get-PSAccounts

        foreach ($Account in $VendorAccounts.GetEnumerator())
        {
            $AccountExists = $GradientAccounts | Where-Object { $_.id -eq $Account.Value.id }
            if (!$AccountExists -and $Account.Value.id)
            {
                $CreateAccountMappingDto = Initialize-PSCreateMappingProperty $Account.Value.name "" $Account.Value.id.ToString()
                New-PSAccount $CreateAccountMappingDto
                Write-Host "Account created in Synthesize API for $( $Account.Value.name )." -ForegroundColor Green
                $createdAccounts++
            }
        }
    }
    catch {
        throw "An error occurred while creating account: $_"
    }
}
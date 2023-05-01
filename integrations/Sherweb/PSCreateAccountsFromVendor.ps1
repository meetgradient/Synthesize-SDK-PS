Function Invoke-SyncAccounts {
    Param() Process {
        $companies = Get-Companies
        return Invoke-CreateAccounts $companies
    }
}


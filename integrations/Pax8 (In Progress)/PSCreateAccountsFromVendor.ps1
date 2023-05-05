Function Invoke-SyncAccounts {
    Param() Process {
        $CompanyList = Get-Pax8Companies
        return Invoke-CreateAccounts $CompanyList
    }
}


Function Invoke-SyncAccounts {
    Param() Process {
        $contactCountByCompanyAndType = Get-ContactDetails
        return Invoke-CreateAccounts $contactCountByCompanyAndType
    }
}


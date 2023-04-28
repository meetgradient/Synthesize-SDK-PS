Function Invoke-SyncAccounts {
    Param() Process {
        $orgData = Get-OrganizationsReport
        return Invoke-CreateAccounts $orgData
    }
}
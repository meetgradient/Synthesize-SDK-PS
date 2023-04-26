Function Invoke-SyncAccounts {
    Param() Process {
        $organizations = Invoke-GetOrganizations
        return Invoke-CreateAccounts $organizations
    }
}


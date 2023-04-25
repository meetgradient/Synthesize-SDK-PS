Function Invoke-SyncAccounts {
    Param() Process {
        $sites = Invoke-GetAccountSites
        return Invoke-CreateAccounts $sites
    }
}


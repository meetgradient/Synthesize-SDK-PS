Function Invoke-SyncAccounts {
    Param() Process {
        $sitesDictionary = Get-AllAccountsFromVendor
        return Invoke-CreateAccounts $sitesDictionary
    }
}


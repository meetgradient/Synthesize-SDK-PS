Function Invoke-SyncAccounts {
    Param() Process {
        $sitesDictionary = GetVendorAccounts
        return Invoke-CreateAccounts $sitesDictionary
    }
}


Function Invoke-SyncAccounts {
    Param() Process {
        $SiteDictionary = Get-WebrootDetails
        return Invoke-CreateAccounts $SiteDictionary
    }
}

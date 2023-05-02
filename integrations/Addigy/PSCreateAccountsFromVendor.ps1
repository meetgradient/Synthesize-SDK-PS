Function Invoke-SyncAccounts {
    Param() Process {
        $policiesDictionary = Get-Policies
        return Invoke-CreateAccounts $policiesDictionary
    }
}


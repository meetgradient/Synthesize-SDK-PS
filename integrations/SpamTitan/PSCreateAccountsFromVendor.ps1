Function Invoke-SyncAccounts {
    Param() Process {
        $usage = Get-SpamTitanDetails
        return Invoke-CreateAccounts $usage
    }
}


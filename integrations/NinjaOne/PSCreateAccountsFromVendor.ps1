Function Invoke-SyncAccounts {
    Param() Process {
        $Organizations = Get-Organizations
        return Invoke-CreateAccounts $Organizations
    }
}


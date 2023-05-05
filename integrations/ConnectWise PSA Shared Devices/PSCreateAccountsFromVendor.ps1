Function Invoke-SyncAccounts {
    Param() Process {
        $configDetails = Get-ConfigurationDetails
        return Invoke-CreateAccounts $configDetails
    }
}


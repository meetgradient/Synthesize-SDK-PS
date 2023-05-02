Function Invoke-SyncAccounts {
    Param() Process {
        $Accounts = Invoke-ProofpointAccounts
        return Invoke-CreateAccounts $Accounts
    }
}


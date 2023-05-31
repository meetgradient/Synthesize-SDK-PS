Function Invoke-SyncAccounts {
    Param()
    Process {
        $Clients = Get-usecureClients
        return Invoke-CreateAccounts $Clients
    }
}


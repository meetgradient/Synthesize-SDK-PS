Function Invoke-SyncAccounts {
    Param() Process {
        $tenants = Get-AuvikTenants
        return Invoke-CreateAccounts $tenants
    }
}


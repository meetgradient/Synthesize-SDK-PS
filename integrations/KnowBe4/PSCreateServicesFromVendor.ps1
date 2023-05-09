 Function Invoke-SyncServices {
    Param(
    ) Process {
        $propertiesToCreateServices = GetVendorServices
        return Invoke-CreateServices $propertiesToCreateServices "https://meetgradient.com" "phil.flamingo@meetgradient.com"
    }
}
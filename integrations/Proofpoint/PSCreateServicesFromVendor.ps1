 Function Invoke-SyncServices {
    Param(
    ) Process {
        $propertiesToCreateServices = Get-VendorServices
        return Invoke-CreateServices $propertiesToCreateServices "https://meetgradient.com" "phil.flamingo@meetgradient.com"
    }
}
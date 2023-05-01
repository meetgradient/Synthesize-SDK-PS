 Function Invoke-SyncServices {
    Param(
    ) Process {
        $RequiredServices = GetVendorServices
        return Invoke-CreateServices $RequiredServices "https://meetgradient.com" "phil.flamingo@meetgradient.com"
    }
}
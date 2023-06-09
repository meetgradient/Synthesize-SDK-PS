 Function Invoke-SyncServices {
    Param(
    ) Process {
        $RequiredServices = Get-AllServicesFromVendor
        return Invoke-CreateServices $RequiredServices "https://meetgradient.com" "phil.flamingo@meetgradient.com"
    }
}
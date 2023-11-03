 Function Invoke-SyncServices {
    Param(
    ) Process {
        $RequiredServices = Get-AllServicesFromVendor
        return Invoke-CreateServiceMappings $RequiredServices
    }
}
Function Invoke-Authenticate {
    Param() Process {
        Invoke-PSVendorApiControllerGetOrganizationIntegration
        Write-Host "Authenticated with Gradient MSP"
    }
}
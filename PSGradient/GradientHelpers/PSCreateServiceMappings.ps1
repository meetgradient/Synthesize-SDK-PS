function Invoke-CreateServiceMappings {
    param(
        [PSCustomObject[]]$VendorServices
    )
    try
    {
        $CreatedServices = 0
        $GradientServices = Get-PSServices

        foreach ($Service in $VendorServices.GetEnumerator())
        {
            $VendorExists = $GradientServices | Where-Object { $_.id -eq $Service.Name }
            if (!$VendorExists)
            {
                if($Serivce.Name -eq "") {
                    Write-Host $service
                    continue
                }
                $CreateVendorSkuDto = Initialize-PSCreateMappingProperty $Service.Name $Service.Description $Service.Name
                New-PSServiceMappingObject @($CreateVendorSkuDto)
                Write-Host "Service created for $($Service)." -ForegroundColor Green
                $CreatedServices++
            }
        }
        Invoke-UpdateStatus
    }
    catch {
        throw "An error occurred while creating service: $_"
    }
}
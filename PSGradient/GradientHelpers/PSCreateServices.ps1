function Invoke-CreateServices {
    param(
        [PSCustomObject[]]$VendorServices,
        [string] $SupportArticle,
        [string] $Contact
    )
    try
    {
        $CreatedServices = 0
        $GradientServices = Get-PSVendor

        foreach ($Service in $VendorServices.GetEnumerator())
        {
            $VendorExists = $GradientServices.data.skus | Where-Object { $_.name -eq $Service.Name }
            if (!$VendorExists)
            {
                $CreateVendorSkuDto = Initialize-PSCreateServiceRequest $Service.Name $Service.Description $SupportArticle $Contact $Service.Category $Service.Subcategory
                New-PSVendorService $CreateVendorSkuDto
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
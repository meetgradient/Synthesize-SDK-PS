Function Invoke-GetServiceIds {
    Param() Process {
        try {
            #get services created in gradient
            $vendorData = Get-PSVendor
            $skus = $vendorData.data.skus
            $skuServiceIds = @{}
            foreach ($sku in $skus) {
                $skuServiceIds[$sku.name] = $sku._id
            }
            return $skuServiceIds
        } catch {
            Write-Host $_
            throw 'An error occurred while getting service IDs. Script execution stopped.'
        }
    }
}

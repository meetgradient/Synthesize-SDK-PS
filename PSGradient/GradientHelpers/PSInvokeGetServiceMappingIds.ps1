Function Invoke-GetServiceMappingIds {
    Param() Process {
        try {
            #get services created in gradient
            $GradientServices = Get-PSServices
            $skuServiceIds = @{}
            foreach ($sku in $GradientServices) {
                write-Host $sku
                $skuServiceIds[$sku.name] = $sku._id
            }
            return $skuServiceIds
        } catch {
            Write-Error $_
            throw 'An error occurred while getting service IDs. Script execution stopped.'
        }
    }
}

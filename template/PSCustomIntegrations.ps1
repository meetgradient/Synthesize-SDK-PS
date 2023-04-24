Function Invoke-AuthenticateVendorAPI {
    Process {
        $Authenticated =
        Write-Host $Authenticated
        return 0
    }
}

function Get-AllAccountsFromVendor {
    param()
    Process {
        $Accounts = @()
        $response = Invoke-WebRequest | ConvertFrom-Json
        $Accounts += $response.accounts
        return $Accounts # [{id: 123, name:"account-name"}]
    }
}

Function Get-AllServicesFromVendor {
    Process {
        $Services = @()
        $response = Invoke-WebRequest | ConvertFrom-Json
        $Services += $response.services
        return $Services # [{Name: "service-name", Description: "service-description", Category: ServiceCategoryEnum, Subcategory: ServiceSubCategoryEnum}]
    }
}

Function Get-AccountUsage {
    param(
    [string] $AccountId
    )
    Process{
        $AccountUsage = @()
        $response = Invoke-WebRequest | ConvertFrom-Json
        $AccountUsage += $response.usage
        return $AccountUsage #Format is unique for each vendor, and how it is implemented in PSSyncUsage.ps1
    }
}
Function Invoke-GetToken {
    Process {
        $RESTAPIUser = $env:USERNAME
        $RESTAPIPassword = $env:PASSWORD

        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Content-Type", "application/x-www-form-urlencoded")

        $body = "grant_type=password&username=$RestAPIUser&password=$RestAPIPassword"

        $response = Invoke-RestMethod "https://$env:VAC_SERVER/api/v3/token" -Method 'POST' -Headers $headers -Body $body
        $token = $response.access_token

        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Authorization", "Bearer $token")
        return $headers
    }
}

Function Invoke-AuthenticateVendorAPI {
    Process {
        Invoke-GetToken
        return 0
    }
}

function Get-AllAccountsFromVendor {
    param()
    Process {
        $headers = Invoke-GetToken
        $CompaniesURI = 'organizations/companies?select=[{"propertyPath":"name"},{"propertyPath":"instanceUid"},{"propertyPath":"status"}]&filter=[{"property":"status","operation":"equals","value":"Active"}]'
        $RequestURL = "https://$Env:VAC_SERVER/api/v3/$CompaniesURI"
        $Limit = 100
        $Offset = 0
        $Total = 0
        $Accounts = @()
        do {
            try {
                $RequestURL = "https://$Env:VAC_SERVER/api/v3/$CompaniesURI&limit=$limit&offset=$offset"
                $response = Invoke-RestMethod $RequestURL -Method 'Get' -Headers $headers
                $Total = $response.meta.pagingInfo.count
                $Offset += $Limit
                $Accounts += $response.data
            } catch {
                Write-Error $_
                $Total = 0
            }
        } while ($Total -and $Total -gt 0)

        $FormatedAccounts = @{}

        ForEach($Account in $Accounts) {
                $id = $Account.instanceUid
                $name = $Account.name
                $AccountData = @{
                    "id" = $id
                    "name" = $name
                }
                if($id) {
                    $FormatedAccounts[$id] = $AccountData
                }

        }
        return $FormatedAccounts
    }
}

Function Get-AllServicesFromVendor {
    Process {
        $headers = Invoke-GetToken
        $ServicesURI = 'organizations/companies/usage'
        $Limit = 1
        $Services = @()
            try {
                $RequestURL = "https://$Env:VAC_SERVER/api/v3/${ServicesURI}?limit=$limit"
                $response = Invoke-RestMethod $RequestURL -Method 'Get' -Headers $headers
                $data = $response.data[0].counters
                ForEach($Service in $data) {
                    $name = $Service.type
                    $ServiceData = @{
                        "name" = $name
                        "Description" = $name
                        "Category" = "other"
                        "Subcategory" = "other"
                    }
                    if($name) {
                        $Services += $ServiceData
                    }
                }
            } catch {
                Write-Error $_
            }

        return $Services # [{Name: "service-name", Description: "service-description", Category: ServiceCategoryEnum, Subcategory: ServiceSubCategoryEnum}]
    }
}

Function Get-AccountUsage {
    Process{
            $headers = Invoke-GetToken
            $UsageURI = 'organizations/companies/usage'
            $Limit = 100
            $Offset = 0
            $Total = 0
            $Usage = @()

            do {
                try {
                    $RequestURL = "https://$Env:VAC_SERVER/api/v3/${UsageURI}?limit=$limit&offset=$offset"
                    $response = Invoke-RestMethod $RequestURL -Method 'Get' -Headers $headers
                    $Total = $response.meta.pagingInfo.count
                    $Offset += $Limit
                    $Usage += $response.data
                } catch {
                    Write-Error $_
                    $Total = 0
                }
            } while ($Total -and $Total -gt 0)

            $FormatedUsage = @()

            ForEach($Account in $Usage) {
                $AccountId = $Account.companyUid
                ForEach($Counter in $Account.counters) {
                    $UsageData = @{
                        "count" = $Counter.value
                        "serviceName" = $Counter.type
                        "accountId" = $AccountId
                    }
                    if($AccountId) {
                        $FormatedUsage += $UsageData
                    }
                }
            }

            return $FormatedUsage
    }
}
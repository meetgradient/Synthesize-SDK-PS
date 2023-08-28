function Get-ZoneBaseUri {
    param (
    )

    $zoneInfoUri = "http://webservices.autotask.net/atservicesrest/v1.0/zoneInformation?user=$($Env:USERNAME)"

    $zoneInfo = Invoke-RestMethod -Uri $zoneInfoUri -Method 'Get'

    # Return the WebServices URL
    return $zoneInfo.url
}

function Invoke-AutotaskPSA {
    param (
        [string]$contentType = "application/json"
    )

    # Define headers
    $headers = @{
        "Accept"                = $contentType
        "ApiIntegrationCode"    = $Env:INTEGRATION_CODE
        "UserName"              = $Env:USERNAME
        "Secret"                = $Env:PASSWORD
        "Content-Type"          = $contentType
    }

    # Determine the correct base URI for the zone using the headers
    $global:AutotaskBaseUri = Get-ZoneBaseUri

    # Return headers for further use in API calls
    return $headers
}

function Invoke-WithExponentialBackoff {
    param (
        [scriptblock]$ScriptBlock,
        [int]$maxRetries = 5,
        [int]$delay = 2
    )

    $retryCount = 0
    while ($retryCount -lt $maxRetries) {
        try {
            & $ScriptBlock
            return
        } catch {
            $retryCount++
            Start-Sleep -Seconds ($delay * [Math]::Pow(2, $retryCount))
            if ($retryCount -ge $maxRetries) {
                throw $_.Exception
            }
        }
    }
}

function Get-Companies {
    param (
        [int]$maxRecords = 500,
        [array]$includeFields = @(),
        [string]$baseUri = (Get-ZoneBaseUri),
        [string]$endpoint = "V1.0/Companies/query"
    )

    $headers = Invoke-AutotaskPSA

    $body = @{
        "MaxRecords"    = $maxRecords
        "IncludeFields" = $includeFields
        "Filter"        = @(
        @{
            "op"    = "gt"
            "field" = "id"
            "value" = 0
            "udf"   = $false
            "items" = @()
        }
        )
    } | ConvertTo-Json

    $companies = @{}
    $maxRetries = 5
    $retryCount = 0
    $sleepTime = 2
    $currentPage = 1

    do {
        try {
            $response = Invoke-RestMethod -Uri "$($baseUri)$($endpoint)" -Method Post -Headers $headers -Body $body

            # Write-Debug "API Response: $response" # For Debugging

            if ($response -and $response.items) {
                foreach ($company in $response.items) {
                    $orgData = @{
                        'name' = $company.companyName
                        'id'   = $company.id
                    }

                    $companies[$company.id] = $orgData
                }

                Write-Host "Retrieved page $currentPage of companies"

                $currentPage++

                # Handle pagination
                if ($response.pageDetails.nextPageUrl) {
                    # Extract just the endpoint from the nextPageUrl
                    $endpoint = ($response.pageDetails.nextPageUrl -split $baseUri)[1]
                } else {
                    $endpoint = $null
                }

                $retryCount = 0  # reset retries since the request was successful

            } else {
                Write-Host "No company data found on page $currentPage. Skipping..."
                $currentPage++
                if ($response.pageDetails.nextPageUrl) {
                    $endpoint = ($response.pageDetails.nextPageUrl -split $baseUri)[1]
                } else {
                    $endpoint = $null
                }
            }

        } catch {
            Write-Error $_.Exception.Message
            if ($retryCount -ge $maxRetries) {
                Write-Error "Max retries reached. Exiting."
                return
            }

            $retryCount++
            Start-Sleep -Seconds ($sleepTime * $retryCount)
        }

    } while ($endpoint)

    return $companies
}

function Get-Configurations {
    param (
        [int]$maxRecords = 500,
        [array]$includeFields = @(),
        [string]$baseUri = (Get-ZoneBaseUri),
        [string]$endpoint = "V1.0/ConfigurationItems/query"
    )

    $headers = Invoke-AutotaskPSA

    $results = @()
    $maxRetries = 5
    $retryCount = 0
    $sleepTime = 2
    $currentPage = 1

    do {
        try {
            $body = @{
                "MaxRecords"    = $maxRecords
                "IncludeFields" = $includeFields
                "Filter"        = @(
                @{
                    "op"    = "gt"
                    "field" = "id"
                    "value" = 0
                    "udf"   = $false
                    "items" = @()
                }
                )
            } | ConvertTo-Json -Depth 5

            $response = Invoke-RestMethod -Uri "$($baseUri)$($endpoint)" -Method Post -Headers $headers -Body $body

            if ($response) {
                Write-Host "Retrieved page $currentPage of configurations"
                $currentPage++

                # Handle pagination
                if ($response.pageDetails.nextPageUrl) {
                    # Extract just the endpoint from the nextPageUrl
                    $endpoint = ($response.pageDetails.nextPageUrl -split $baseUri)[1]
                } else {
                    $endpoint = $null
                }

                $results += $response.items
            }

        } catch {
            Write-Error $_.Exception.Message
            if ($retryCount -ge $maxRetries) {
                Write-Error "Max retries reached. Exiting."
                return
            }

            $retryCount++
            Start-Sleep -Seconds ($sleepTime * $retryCount)
        }

    } while ($endpoint)  # Continue while there's a new endpoint for pagination

    # Write-Host "Retrieved a total of $($results.Count) configuration items." # For Debugging

    # Retrieve Configuration Item Types
    Write-Host "Retrieving configuration item types..."
    $configItemTypes = Invoke-RestMethod -Uri "$($baseUri)/V1.0/ConfigurationItemTypes/query" -Method Post -Headers $headers -Body $body
    # Write-Host "Retrieved $($configItemTypes.items.Count) configuration item types." # For Debugging

    # Mapping Configuration Item Types
    $configItemTypesMapping = @{}
    foreach ($item in $configItemTypes.items) {
        $configItemTypesMapping[$item.id] = $item.name
    }

    # Create a list for configurations
    $configurations = @()

    foreach ($configItem in $results) {
        if ($null -ne $configItem.companyID) {
            $configItemType = $configItem.configurationItemType
            $configItemTypeName = $configItemTypesMapping[$configItemType]

            $configData = @{
                'CompanyId' = $configItem.companyID
                'Type' = $configItemTypeName
                'Id' = $configItem.id
            }

            # Adding configuration data to the list
            $configurations += $configData
        }
    }

    return $configurations
}

Function GetVendorServices {
    Process {
        $propertiesToCreateServices = @(
        @{ Name = "Managed Workstations"; Description = "Laptops and Desktops"; Category = "other"; Subcategory = "other" },
        @{ Name = "Managed Servers"; Description = "Servers"; Category = "other"; Subcategory = "other" },
        @{ Name = "Network Devices"; Description = "Devices Not Equal to Laptops, Desktops, Servers and ESXi Host"; Category = "other"; Subcategory = "other" }
        )
        return $propertiesToCreateServices
    }
}

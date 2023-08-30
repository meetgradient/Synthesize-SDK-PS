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

<#function Invoke-WithExponentialBackoff {
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
}#>

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

function Get-Contacts {
    param (
        [int]$maxRecords = 500,
        [array]$includeFields = @(),
        [string]$baseUri = (Get-ZoneBaseUri),
        [string]$endpoint = "V1.0/Contacts/query"
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
                Write-Host "Retrieved page $currentPage of contacts"
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

    # Create a hashtable for contacts
    $contacts = @{}

    foreach ($contactItem in $results) {
        if ($null -ne $contactItem.companyID) {
            $userDefinedFields = $contactItem.userDefinedFields | ForEach-Object {
                @{
                    'name' = $_.name
                    'value' = $_.value
                }
            }

            $contacts[$contactItem.companyID] = $userDefinedFields
        }
    }

    return $contacts
}

Function GetVendorServices {

    Process {
        # Retrieve contacts
        $contacts = Get-Contacts

        $uniqueUserDefinedFieldsValues = @{}

        # Extract unique user-defined field values from the contacts
        foreach ($contact in $contacts.Values) {
            foreach ($field in $contact) {
                $fieldValue = $field['value']
                if (![string]::IsNullOrWhiteSpace($fieldValue)) {
                    $uniqueUserDefinedFieldsValues[$fieldValue] = $true
                }
            }
        }

        $baseServices = @()

        # Adding services based on unique user-defined fields values
        foreach ($value in $uniqueUserDefinedFieldsValues.Keys) {
            $baseServices += @{
                Name = $value;
                Description = "Generated from user-defined field value: $value";
                Category = "other";
                Subcategory = "other";
            }
        }

        return $baseServices
    }
}


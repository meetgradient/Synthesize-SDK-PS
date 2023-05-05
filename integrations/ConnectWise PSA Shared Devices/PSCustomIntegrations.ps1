function Invoke-ConnectWisePSA {
    param (
    )

    # Concatenate company_id and public_key to form username
    $username = $Env:CLIENT_ID + '+' + $Env:PUBLIC_KEY
    # Concatenate username and private_key to form password
    $password = $Env:PRIVATE_KEY
    # Encode username:password in base64
    $auth_string = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($username + ':' + $password))

    # Set up headers for API request
    $headers = @{ Authorization = 'Basic ' + $auth_string }

    return $headers
}

function Get-ConfigurationDetails {
    param (
    )
    # Authenticate with ConnectWise PSA API
    $headers = @{
        'Authorization' = (Invoke-ConnectWisePSA).Authorization
        'clientId' = $Env:CLIENT_ID
    }

    # Sends a GET request to the specified API endpoint and retrieves a list of configuration objects.
    $response = Invoke-RestMethod -Uri 'https://staging.connectwisedev.com/v4_6_release/apis/3.0/company/configurations' `
        -Method 'GET' `
        -Headers $headers

    # Filters the configuration objects to retrieve only those with a "License" type
    $licenseConfigs = $response | Where-Object { ($_.type.name -eq "License") }

    # Initializes an array to store the output hashtables
    $configDetails = @()

    # Creates dictionaries that store the number of configurations per company, the number of configurations that contain "shared" in the contact name, and the number of units not shared per company.
    $configCountsByCompanyId = @{}
    $sharedCountsByCompanyId = @{}
    $notSharedUnitCountByCompanyId = @{}

    foreach ($config in $response) {
        if ($config.type.name -eq "License") {
            $companyId = $config.company.id
            if (-not $configCountsByCompanyId.ContainsKey($companyId)) {
                $configCountsByCompanyId[$companyId] = [int]0
                $sharedCountsByCompanyId[$companyId] = [int]0
                $notSharedUnitCountByCompanyId[$companyId] = [int]0
            }
            $configCountsByCompanyId[$companyId]++
            if ($config.contact.name -like "*shared*") {
                $sharedCountsByCompanyId[$companyId]++
            } else {
                $unitCount = $config.licenses | Where-Object { $_.unitAssignment.assignmentType -eq "NOT_SHARED" } | Measure-Object -Property units -Sum | Select-Object -ExpandProperty Sum
                $notSharedUnitCountByCompanyId[$companyId] += $unitCount ?? 0
            }
        }
    }

    # Outputs the dictionary with the total number of configurations per company, the number of configurations that contain "shared" in the contact name, and the total number of units not shared per company.
    foreach ($companyId in $configCountsByCompanyId.Keys) {
        $companyName = ($licenseConfigs | Where-Object { $_.company.id -eq $companyId } | Select-Object -First 1).company.name
        $sharedCount = $sharedCountsByCompanyId[$companyId]
        $notSharedCount = $configCountsByCompanyId[$companyId] - $sharedCountsByCompanyId[$companyId]

        # Creates a hashtable with the required information
        $outputHashtable = @{
            'id' = $companyId
            'name' = $companyName
            'sharedcounts' = $sharedCount
            'notsharedcounts' = $notSharedCount
        }

        # Adds the hashtable to the output array
        $configDetails += $outputHashtable
    }

    # Returns the output array
    return $configDetails
}

Function GetVendorServices {
    Process {
        $propertiesToCreateServices = @(
        @{ Name = "Shared Devices"; Description = "Total Shared Devices"; Category = "other"; Subcategory = "other" },
        @{ Name = "Not Shared Devices"; Description = "Total Not Shared Devices"; Category = "other"; Subcategory = "other" })
        return $propertiesToCreateServices
    }
}
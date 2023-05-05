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
    $response = Invoke-RestMethod -Uri "$( $Env:BASE_URL )/v4_6_release/apis/3.0/company/configurations" -Method 'GET' -Headers $headers

    # Filters the configuration objects to retrieve only those with a "License" type.
    $licenseConfigs = $response | Where-Object { $_.type.name -eq "License" }

    # Creates a dictionary that stores the number of license configurations for each company ID.
    $unitCountByCompanyId = @{}
    foreach ($config in $licenseConfigs) {
        $companyId = $config.company.id
        if ($unitCountByCompanyId.ContainsKey($companyId)) {
            $unitCountByCompanyId[$companyId] += 1
        } else {
            $unitCountByCompanyId[$companyId] = 1
        }
    }

    $configDetails = @()
    foreach ($companyId in $unitCountByCompanyId.Keys) {
        $companyName = ($licenseConfigs | Where-Object { $_.company.id -eq $companyId } | Select-Object -First 1).company.name
        $configDetails += @{
            'id' = $companyId
            'name' = $companyName
            'quantity' = $unitCountByCompanyId[$companyId]
        }
    }

    return $configDetails
}

Function GetVendorServices {
    Process {
        $propertiesToCreateServices = @(
        @{ Name = "Configurations"; Description = "Total Configurations by Configuration Type"; Category = "other"; Subcategory = "other" }
        )
        return $propertiesToCreateServices
    }
}
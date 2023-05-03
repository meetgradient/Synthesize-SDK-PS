#The function implements an exponential backoff algorithm for making API requests with retry logic, with a configurable maximum number of retries and initial delay time.
#The Invoke-SherwebAPI function is used to obtain an authentication header before making the API request using Invoke-WebRequest.

function Invoke-ExponentialBackoff
{
    param (
        [Parameter(Mandatory = $true)][string] $Uri,
        [Parameter(Mandatory = $true)][string] $Method,
        [hashtable] $Headers,
        [int] $MaxRetries = 5,
        [int] $InitialDelaySeconds = 2,
        [bool] $AuthRequired = $false
    )

    $RetryCount = 0
    $DelaySeconds = $InitialDelaySeconds

    if ($AuthRequired)
    {
        $Headers = Invoke-SherwebAPI
    }

    while ($RetryCount -lt $MaxRetries)
    {
        try
        {
            $Response = Invoke-WebRequest -uri $Uri -Method $Method -Headers $Headers -ErrorAction Stop
            return $Response
        }
        catch
        {
            $StatusCode = $_.Exception.Response.StatusCode.value__
            if ($StatusCode -eq 429 -or ($StatusCode -ge 500 -and $StatusCode -le 599))
            {
                Write-Host "Request failed with status code $StatusCode. Retrying in $( $DelaySeconds ) seconds..."
                Start-Sleep -Seconds $DelaySeconds
                $RetryCount++
                $DelaySeconds = $DelaySeconds * 2
            }
            else
            {
                throw $_
            }
        }
    }

    throw "Failed to make request after $( $MaxRetries ) retries"
}

#The script defines a function named "Invoke-ProofpointAccounts" to retrieve accounts data from Proofpoint API.
#The function uses environment variables for authentication and the ExponentialBackoff function to handle errors.
#The response is converted to JSON format and a dictionary of account data is created using the 'id' field as the key, and the function returns the dictionary.
function Invoke-ProofpointAccounts {
    [CmdletBinding()]
    param (
    )

    Write-Host "Retrieving accounts data..."
    $Endpoint = "/api/v1/billing/$( $Env:ORGANIZATION_DOMAIN )/orgs"

    $Headers = @{
        "X-User" = $Env:USERNAME
        "X-Password" = $Env:PASSWORD
    }

    try {
        $Response = Invoke-ExponentialBackoff -Uri ($Env:BASE_URL + $Endpoint) -Headers $Headers -Method 'GET'
        $JsonResponse = $Response | ConvertFrom-Json

        # Extract and create dictionary using the 'id' as the key
        $Accounts = @{}
        foreach ($item in $JsonResponse) {
            $AccountsData = @{
                "id"               = $item.eid
                "name"             = $item.name
            }
            $Accounts[$item.eid] = $AccountsData
        }

        return $Accounts
    }
    catch {
        Write-Error "Error retrieving Proofpoint endpoints: $_"
    }
}

#The script defines a function named "Invoke-ProofpointLicensing" to retrieve billing data from Proofpoint API.
#The function uses the environment variables for authentication and ExponentialBackoff function to handle errors.
#The response is converted to JSON format and an array of licensing data is created with specific fields.
#The function returns the array of licensing data, and if there is an error, it displays an error message.
function Invoke-ProofpointLicensing {
    [CmdletBinding()]
    param (
    )

    Write-Host "Retrieving billing data..."
    $Endpoint = "/api/v1/billing/$( $Env:ORGANIZATION_DOMAIN )/orgs"

    $Headers = @{
        "X-User" = $Env:USERNAME
        "X-Password" = $Env:PASSWORD
    }

    try {
        $Response = Invoke-ExponentialBackoff -Uri ($Env:BASE_URL + $Endpoint) -Headers $Headers -Method 'GET'
        $JsonResponse = $Response | ConvertFrom-Json
        Write-Host "JsonResponse: $($JsonResponse)"  # Add this line to log the JsonResponse value

        # Extract and create array
        $Licensing = @()
        foreach ($item in $JsonResponse) {
            Write-Host "Processing item: $($item)"  # Add this line to log the current item
            $Licensing += @{
                'id'               = $item.eid
                'name'             = $item.name
                'licensing_package'= $item.licensing_package
                'quantity'         = $item.active_users
            }
        }

        return $Licensing
    }
    catch {
        Write-Error "Error retrieving Proofpoint endpoints: $_"
    }
}

#The script defines a function named "Get-VendorServices" to create an array of service properties from unique licensing packages retrieved using the "Invoke-ProofpointLicensing" function.
#The function creates a hashtable to keep track of unique licensing packages and loops through each licensing package to identify unique packages.
#The function then creates an array of service properties for each unique package, including the package name, a description of Proofpoint's services, and the service category and subcategory.
function Get-VendorServices {
    param ()

    $licensingData = Invoke-ProofpointLicensing
    $uniqueLicensingPackages = @{}

    # Loop through each licensing package
    foreach ($item in $licensingData) {
        $licensingPackageName = $item.'licensing_package'

        if (-not [string]::IsNullOrEmpty($licensingPackageName)) {
            # Write-Host "Processing licensing package: $($licensingPackageName)"

            if (-not $uniqueLicensingPackages.ContainsKey($licensingPackageName)) {
                $uniqueLicensingPackages[$licensingPackageName] = $item
            }
        }
    }

    $propertiesToCreateServices = @()

    foreach ($package in $uniqueLicensingPackages.Values) {
        $packageName = $package.'licensing_package'.ToString()

        $properties = @{
            Name = $packageName
            Description = "Proofpoint helps protect people, data and brands against cyber attacks. Offering compliance and cybersecurity solutions for email, web, cloud, and more."
            Category = "security"
            Subcategory = "email security"
        }
        $propertiesToCreateServices += ,($properties)
    }

    return $propertiesToCreateServices
}

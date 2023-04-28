#The Invoke-NinjaOne function is used to obtain an authentication header for a NinjaRMM API.
#The function constructs an authentication request body, sends it to the API endpoint using Invoke-WebRequest, extracts the access token from the response content, and constructs an authentication header with the access token.

function Invoke-NinjaOne
{
    param (
    )

    try
    {
        $AuthBody = @{
            'grant_type' = 'client_credentials'
            'client_id' = $Env:API_KEY
            'client_secret' = $Env:API_SECRET_KEY
            'scope' = 'monitoring'
        }

        $Result = Invoke-WebRequest -uri "$( $Env:API_URL )/ws/oauth/token" -Method POST -Body $AuthBody -ContentType 'application/x-www-form-urlencoded'

        $AuthHeader = @{
            'Authorization' = "Bearer $( ($Result.content | ConvertFrom-Json).access_token )"
        }

        return $AuthHeader
    }
    catch
    {
        Write-Host "Error: $( $_.Exception.Message )"
        return $null
    }
}

#The function implements an exponential backoff algorithm for making API requests with retry logic, with a configurable maximum number of retries and initial delay time.
#The Invoke-NinjaOne function is used to obtain an authentication header before making the API request using Invoke-WebRequest.

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
        $Headers = Invoke-NinjaOne
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

#The function retrieves a list of vendor accounts (organizations) from a NinjaOne API endpoint, using Invoke-ExponentialBackoff to implement an exponential backoff algorithm for making the API request with retry logic.
#The function constructs a hashtable that maps organization IDs to their respective names, and returns this hashtable. If an error occurs during execution of the function, the error message is written out and the script execution is stopped.

function Get-Organizations
{
    param (
    )

    try
    {
        $PageSize = 100
        $After = 0
        $Headers = Invoke-NinjaOne

        if ($null -eq $Headers)
        {
            throw 'Headers are null'
        }

        $Uri = "$( $Env:API_URL )/v2/organizations?pageSize=$PageSize&after=$After"
        $Response = Invoke-ExponentialBackoff -Uri $Uri -Method GET -Headers $Headers | ConvertFrom-Json

        if ($null -eq $Response)
        {
            throw 'Response is null'
        }

        $Organizations = @{ }
        foreach ($Organization in $Response)
        {
            $id = $Organization.id
            $name = $Organization.name
            $OrganizationData = @{
                "id" = $id
                "name" = $name
            }
            $Organizations[$id] = $OrganizationData
        }

        return $Organizations
    }
    catch
    {
        Write-Error $_
        throw 'An error occurred while getting organizations. Script execution stopped.'
    }
}

#The function retrieves a list of devices from a NinjaOne API endpoint, using Invoke-ExponentialBackoff to implement an exponential backoff algorithm for making the API request with retry logic.
#The function constructs an array of device data for each device in the response, including the device ID, parent device ID, organization ID, location ID, node class, and offline status, and returns this array. If an error occurs during execution of the function, the error message is written out and $null is returned.

function Get-Devices
{
    param (
        [int] $PageSize = 100,
        [int] $After = 0,
        [bool] $Offline = $false
    )

    try
    {
        $Devices = @()
        $Response = $null
        $Headers = Invoke-NinjaOne

        do
        {
            $Uri = "$( $Env:API_URL )/v2/devices?pageSize=$PageSize&after=$After&offline=$Offline"
            $Response = Invoke-ExponentialBackoff -Uri $Uri -Method GET -Headers $Headers | ConvertFrom-Json

            foreach ($Device in $Response)
            {
                $DeviceData = @{
                    "id" = $Device.id
                    "parentDeviceId" = $Device.parentDeviceId
                    "organizationId" = $Device.organizationId
                    "locationId" = $Device.locationId
                    "nodeClass" = $Device.nodeClass
                    "offline" = $Device.offline
                }
                $Devices += $DeviceData
            }

            $After = $Response[-1].id
        } while ($Response.Count -eq $PageSize)

        return $Devices
    }
    catch
    {
        Write-Host "Error: $( $_.Exception.Message )"
        return $null
    }
}

#The function returns an array of hashtables, with each hashtable containing information about a service offered by a vendor, including the service name, description, category, and subcategory.
#The services included in the array are related to security and other device types, such as workstations, servers, and network devices.
#If you need to modify the name of an existing service or add new services, you can do so here. After modifying the services, make sure to create the respective counts in the Invoke-SyncUsage function.

Function GetVendorServices
{
    Process {
        $propertiesToCreateServices = @(
        @{ Name = "Total Devices"; Description = "Total Devices"; Category = "security"; Subcategory = "other" },
        @{ Name = "Total Servers"; Description = "Total Servers"; Category = "security"; Subcategory = "other" },
        @{ Name = "Total Workstations"; Description = "Total Workstations"; Category = "security"; Subcategory = "other" },
        @{ Name = "Total Network Devices"; Description = "Total Network Devices"; Category = "security"; Subcategory = "other" },
        @{ Name = "Total Virtual Machines"; Description = "Total Virtual Machines"; Category = "security"; Subcategory = "other" }
        )
        return $propertiesToCreateServices
    }
}
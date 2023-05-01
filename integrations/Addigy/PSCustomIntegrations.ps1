#The function implements an exponential backoff algorithm for making API requests with retry logic, with a configurable maximum number of retries and initial delay time.
#The Invoke-SherwebAPI function is used to obtain an authentication header before making the API request using Invoke-WebRequest.

function Invoke-ExponentialBackoff
{
    param (
        [Parameter(Mandatory = $true)][string] $Uri,
        [Parameter(Mandatory = $true)][string] $Method,
        [int] $MaxRetries = 5,
        [int] $InitialDelaySeconds = 2,
        [bool] $AuthRequired = $false
    )

    $RetryCount = 0
    $DelaySeconds = $InitialDelaySeconds

    while ($RetryCount -lt $MaxRetries)
    {
        try
        {
            $Response = Invoke-WebRequest -uri $Uri -Method $Method -ErrorAction Stop
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

function Get-Policies {
    param (
    )

    $url = "$( $Env:BASE_URL )/policies?client_id=$( $Env:CLIENT_ID )&client_secret=$( $Env:CLIENT_SECRET )"

    $response = Invoke-ExponentialBackoff -Uri $url -Method Get

    $responseObject = $response | ConvertFrom-Json

    $policiesDictionary = @{}

    foreach ($item in $responseObject) {
        $policyid = $item.policyId
        $name = $item.name

        $orgData = @{
            "name"  = $name
            "id" = $policyId
        }

        $policiesDictionary[$policyId] = $orgData
    }

    return $policiesDictionary
}

function Get-PolicyDeviceCount {
    param (
        [string]$Env:CLIENT_ID,
        [string]$Env:CLIENT_SECRET
    )

    $policies = Get-Policies

    $policyDeviceCount = @{}

    foreach ($policy in $policies.GetEnumerator()) {
        $policyId = $policy.Value.id
        $name = $policy.Value.name
        Write-Host "Getting device count for Policy ID: $( $policyId ) Policy Name: $( $name )..."
        $url = "$( $Env:BASE_URL )/policies/devices?policy_id=$policyId&client_id=$( $Env:CLIENT_ID )&client_secret=$( $Env:CLIENT_SECRET )"
        Write-Host "URL: $url"

        try {
            $response = Invoke-ExponentialBackoff -Uri $url -Method Get
        } catch {
            Write-Host "Error: $($_)"
            throw
        }

        Write-Host $response

        $devices = $response.Content | ConvertFrom-Json
        $deviceCount = $devices.Count

        if ($deviceCount -gt 0) {
            $policyDeviceCount[$policyId] = @{
                'id' = $policyId
                'name' = $name
                'quantity' = $deviceCount
            }
        }
    }

    return $policyDeviceCount
}

Function GetVendorServices {
    Process {
        $propertiesToCreateServices = @(
        @{ Name = "Total Devices"; Description = "Apple Device Management"; Category = "security"; Subcategory = "mobile device management (MDM)" }
        )
        return $propertiesToCreateServices
    }
}
$VerbosePreference = 'Continue'

# Authorization
function Invoke-HuntressAPI {
    param (
        [string]$Uri,
        [string]$Method,
        [string]$Env:API_KEY,
        [string]$Env:API_SECRET_KEY,
        [int]$MaxRetries = 5,
        [int]$InitialRetryInterval = 2
    )

    $credentials = "$($Env:API_KEY):$Env:API_SECRET_KEY"
    $base64Credentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($credentials))
    $headers = @{
        'Authorization' = "Basic $base64Credentials"
        'Accept'        = 'application/json'
        'Content-Type'  = 'application/json'
    }

    $retryCount = 0
    $retryInterval = $InitialRetryInterval

    do {
        try {
            Write-Verbose "Sending API request: Method=$Method, Uri=$Uri, Headers=$($headers | ConvertTo-Json -Depth 2)"
            $response = Invoke-WebRequest -Uri $Uri -Method $Method -Headers $headers
            $jsonResponse = (ConvertFrom-Json -InputObject $response.Content)
            Write-Verbose "API response: $($jsonResponse | ConvertTo-Json -Depth 2)"
            return $jsonResponse
        } catch {
            $responseError = $_.Exception.Response
            $statusCode = $responseError.StatusCode

            if ($statusCode -eq 429) { # 429 is the HTTP status code for "Too Many Requests"
                $retryCount++
                if ($retryCount -le $MaxRetries) {
                    Write-Warning "API request rate limit reached. Retrying in $retryInterval seconds..."
                    Start-Sleep -Seconds $retryInterval
                    $retryInterval *= 2
                } else {
                    Write-Error "API request failed due to rate limit. Max retries reached."
                    break
                }
            } else {
                Write-Error "API request failed: $_"
                return $null
            }
        }
    } while ($retryCount -le $MaxRetries)
}

# Get Organizations
function Invoke-GetOrganizations {
    param (
    )

    $organizationsApi = "/v1/organizations"
    $organizationsUrl = $Env:API_URL + $organizationsApi

    $organizations = @{}
    $maxRetries = 5
    $retryInterval = 2
    $retryCount = 0

    do {
        try {
            $response = Invoke-HuntressAPI -Uri $organizationsUrl -Method 'Get'

            if ($response -and $response.organizations) {
                # Loop through the organizations and create a hashtable
                foreach ($organization in $response.organizations) {
                    $organizationData = @{
                        "name"         = $organization.name
                        "id"           = $organization.id
                        "agents_count" = $organization.agents_count
                    }
                    $organizations[$organization.id] = $organizationData
                }
                $retryCount = $maxRetries + 1
                Write-Verbose "Organizations fetched: $($organizations.Count)"
            }
        } catch {
            $retryCount++
            if ($retryCount -le $maxRetries) {
                Write-Warning "Error fetching organizations: $_. Retrying in $($retryInterval) seconds..."
                Start-Sleep -Seconds $retryInterval
                $retryInterval *= 2
            } else {
                Write-Error "Error fetching organizations: $_"
                $organizations = @{}
                break
            }
        }
    } while ($retryCount -le $maxRetries)

    return $organizations
}

Function GetVendorServices {
    Process {
        $propertiesToCreateServices = @(
        @{ Name = "Total Agents"; Description = "Managed EDR"; Category = "security"; Subcategory = "other" }
   )
        return $propertiesToCreateServices
    }
}
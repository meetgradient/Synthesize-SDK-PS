#The function implements an exponential backoff algorithm for making API requests with retry logic, with a configurable maximum number of retries and initial delay time.
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
            $Response = Invoke-RestMethod -uri $Uri -Method $Method -Headers $Headers -ErrorAction Stop
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

#This function retrieves a list of groups from KnowBe4's API.
#This function ilters the groups by status and group type to only retrieve active console groups.
#This function then processes the retrieved data and returns a hashtable with information on each group, including its name, ID, and number of members.
#Note that you can modify the group_type filter as needed by following the instructions in the README.md file in this directory.
function Get-KnowBe4Groups {
    [CmdletBinding()]
    param (
    )

    $Uri = "$( $Env:BASE_URL )/v1/groups"

    $Headers = @{
        "Accept" = "application/json"
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $Env:SECRET_API_KEY"
    }

    Write-Host "Sending request to KnowBe4 API..."

    try {
        $Response = Invoke-ExponentialBackoff -Uri $Uri -Headers $Headers -Method Get
    }
    catch {
        Write-Error "Failed to retrieve group data from KnowBe4. Error: $($_.Exception.Message)"
        return
    }

    Write-Host "Successfully retrieved group data from KnowBe4"

    # Filter the groups by status and group type
    Write-Host "Filtering active console groups..."
    $ActiveConsoleGroups = $Response | Where-Object { $_.status -eq "active" -and $_.group_type -eq "console_group" }

    # Initialize an empty hashtable to store the groups
    $GroupList = @{}

    Write-Host "Processing group data..."
    foreach ($Group in $ActiveConsoleGroups) {
        $GroupData = @{
            'name' = $Group.name
            'id' = $Group.id.ToString()
            'quantity' = $Group.member_count
        }
        $GroupList[$Group.id] = $GroupData
    }

    Write-Host "Finished processing group data."

    return $GroupList
}

#This function is used to provide the necessary information to create vendor services in Synthesize API.
Function GetVendorServices
{
    Process {
        $propertiesToCreateServices = @(
        @{
            Name = "Security Awareness Training"; Description = "Number of members in the group"; Category = "security"; Subcategory = "privacy and security awareness training"
        }
        )
        return $propertiesToCreateServices
    }
}
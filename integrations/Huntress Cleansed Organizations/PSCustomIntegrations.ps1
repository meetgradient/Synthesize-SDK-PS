#Summary

#This script groups organizations in the Huntress management console based on their names and calculates the number of agents, workstations, and servers in each group. It cleans the organization names using regular expressions and extracts the last part of the name before the "m" character, enabling the splitting of agent counts into servers and workstations. This usage can be synchronized into Synthesize to reconcile individual services within your PSA. Note that this functionality only applies if you create organizations in the "servers-m-companyname" and "workstations-m-companyname" format in the Huntress management console.
#If you don't require the cleansing and grouping of unique organizations in Huntress, please refer to the other Huntress integration available within the Synthesize SDK PS.

$VerbosePreference = 'Continue'

#The code defines a PowerShell function named "Invoke-HuntressAPI" that sends an API request to the Huntress API, handles rate limiting, and returns the JSON response.
#The function takes several parameters, including the API key and API secret key, and retries failed requests up to a specified maximum number of times.

#Authorization
function Invoke-HuntressAPI
{
    param (
        [string]$Uri,
        [string]$Method,
        [string]$Env:API_KEY,
        [string]$Env:API_SECRET_KEY,
        [int]$MaxRetries = 5,
        [int]$InitialRetryInterval = 2
    )

    $credentials = "$( $Env:API_KEY ):$Env:API_SECRET_KEY"
    $base64Credentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($credentials))
    $headers = @{
        'Authorization' = "Basic $base64Credentials"
        'Accept' = 'application/json'
        'Content-Type' = 'application/json'
    }

    $retryCount = 0
    $retryInterval = $InitialRetryInterval

    do
    {
        try
        {
            Write-Verbose "Sending API request: Method=$Method, Uri=$Uri, Headers=$( $headers | ConvertTo-Json -Depth 2 )"
            $response = Invoke-WebRequest -Uri $Uri -Method $Method -Headers $headers
            $jsonResponse = (ConvertFrom-Json -InputObject $response.Content)
            Write-Verbose "API response: $( $jsonResponse | ConvertTo-Json -Depth 2 )"
            return $jsonResponse
        }
        catch
        {
            $responseError = $_.Exception.Response
            $statusCode = $responseError.StatusCode

            if ($statusCode -eq 429)
            {
                # 429 is the HTTP status code for "Too Many Requests"
                $retryCount++
                if ($retryCount -le $MaxRetries)
                {
                    Write-Warning "API request rate limit reached. Retrying in $retryInterval seconds..."
                    Start-Sleep -Seconds $retryInterval
                    $retryInterval *= 2
                }
                else
                {
                    Write-Error "API request failed due to rate limit. Max retries reached."
                    break
                }
            }
            else
            {
                Write-Error "API request failed: $_"
                return $null
            }
        }
    } while ($retryCount -le $MaxRetries)
}

#Get-Organizations: Retrieves a list of organizations from the API endpoint.
#Get-AgentOrganizationMap: Retrieves a list of agents from the API endpoint and creates a mapping between each agent and its organization.
#Group-Organizations: Groups the organizations by name and aggregates the number of agents associated with each organization.
#Get-OrganizationsReport: Calls the previous functions to retrieve and group the data, and then generates a JSON report that includes the name of each organization, the total number of agents associated with it, and the number of workstations and servers.

#Get Organizations
function Get-Organizations {
    param ()

    $organizationsApi = "/v1/organizations"
    $organizationsUrl = $Env:API_URL + $organizationsApi

    $organizations = @()
    $maxRetries = 5
    $retryInterval = 2
    $retryCount = 0

    do {
        try {
            $response = Invoke-HuntressAPI -Uri $organizationsUrl -Headers $Headers -Method 'Get'
            $organizations = $response.organizations
            $retryCount = $maxRetries + 1
        } catch {
            $retryCount++
            if ($retryCount -le $maxRetries) {
                Write-Warning "Error fetching organizations: $_. Retrying in $($retryInterval) seconds..."
                Start-Sleep -Seconds $retryInterval
                $retryInterval *= 2
            } else {
                Write-Error "Error fetching organizations: $_"
                $organizations = @()
                break
            }
        }
    } while ($retryCount -le $maxRetries)

    return $organizations
}

function Get-AgentOrganizationMap
{
    param (
    )

    $agentsApi = "/v1/agents"
    $agentsUrl = $Env:API_URL + $agentsApi

    $agents = @()
    $maxRetries = 5
    $retryInterval = 2
    $retryCount = 0

    do
    {
        try
        {
            $response = Invoke-HuntressAPI -Uri $agentsUrl -Headers $Headers -Method 'Get'
            $agents = $response.agents
            $retryCount = $maxRetries + 1
        }
        catch
        {
            $retryCount++
            if ($retryCount -le $maxRetries)
            {
                Write-Warning "Error fetching agents: $_. Retrying in $( $retryInterval ) seconds..."
                Start-Sleep -Seconds $retryInterval
                $retryInterval *= 2
            }
            else
            {
                Write-Error "Error fetching agents: $_"
                $agents = @()
                break
            }
        }
    } while ($retryCount -le $maxRetries)

    $agentOrgMap = @{ }
    foreach ($agent in $agents)
    {
        $orgId = $agent.organization_id
        if (-not $agentOrgMap.ContainsKey($orgId))
        {
            $agentOrgMap[$orgId] = @{
                'total' = 0
            }
        }
        $agentOrgMap[$orgId]['total']++
    }

    return $agentOrgMap
}

#The code defines a PowerShell function called "Group-Organizations" that groups a list of organizations based on their names and calculates the number of agents, workstations, and servers in each group.
#The function uses a regular expression to clean the organization name and extract the last part of the name before the "m" character.
#The function returns a hashtable that maps group names to their corresponding agent counts, which can be used for reporting or further analysis.

function Group-Organizations {
    param (
        [Parameter(Mandatory = $true)]
        [array]$Organizations,

        [Parameter(Mandatory = $true)]
        [hashtable]$AgentOrganizationMap
    )

    $orgGroupMap = @{ }
    foreach ($org in $Organizations) {
        $orgId = $org.id
        $orgName = $org.name

        if (-not [string]::IsNullOrEmpty($orgName)) {
            $splitName = $orgName -split '[\.-]'
            $lastPartIndex = $splitName.Count - 1
            for ($i = $lastPartIndex; $i -ge 0; $i--) {
                if ($splitName[$i] -eq "m") {
                    break
                }
            }

            $cleanedNameParts = @()
            for ($j = $i + 1; $j -le $lastPartIndex; $j++) {
                $cleanedNameParts += $splitName[$j]
            }
            $cleanedName = $cleanedNameParts -join '-'
        } else {
            $cleanedName = "Unknown"
        }

        $agentCounts = @{
            'Total' = 0
            'Workstations' = 0
            'Servers' = 0
        }
        if ($AgentOrganizationMap.ContainsKey($orgId)) {
            $agentCounts = $AgentOrganizationMap[$orgId]
        }

        if (-not $orgGroupMap.ContainsKey($cleanedName)) {
            $orgGroupMap[$cleanedName] = @{
                'Total Agents' = 0
                'Workstations' = 0
                'Servers' = 0
                'id' = 0
            }
        }

        $orgGroupMap[$cleanedName]['Total Agents'] += $agentCounts['Total']
        if ($orgName -match 'servers') {
            $orgGroupMap[$cleanedName]['Servers'] += $agentCounts['Total']
        } elseif ($orgName -match 'wkstns' -or $orgName -match 'workstations') {
            $orgGroupMap[$cleanedName]['Workstations'] += $agentCounts['Total']
        }
        $orgGroupMap[$cleanedName]['id'] += $orgId
    }

    return $orgGroupMap
}

#The function retrieves a list of organizations from the Huntress management console and generates a report of the number of agents, workstations, and servers in each organization.
#The function calls the "Group-Organizations" function to group the organizations based on their names and calculate the agent counts, and creates a hashtable called $orgData that maps organization IDs to their corresponding name and agent counts.
#The function returns the $orgData hashtable containing the report data.

function Get-OrganizationsReport {
    param ()

    $organizations = Get-Organizations
    $agentOrgMap = Get-AgentOrganizationMap
    $orgGroupMap = Group-Organizations -Organizations $organizations -AgentOrganizationMap $agentOrgMap

    $orgData = @{}

    foreach ($org in $orgGroupMap.Keys) {
        $groupTotalAgents = $orgGroupMap[$org]['Total Agents']
        $groupWorkstations = $orgGroupMap[$org]['Workstations']
        $groupServers = $orgGroupMap[$org]['Servers']
        $groupID = $orgGroupMap[$org]['id']

        $orgUniqueId = $groupID.ToString()
        $orgName = $org

        $orgData[$orgUniqueId] = @{
            'id' = $orgUniqueId
            'name' = $orgName
            'Total Agents' = $groupTotalAgents
            'Workstations' = $groupWorkstations
            'Servers' = $groupServers
        }
    }

    return $orgData
}

#The "GetVendorServices" function creates vendor services in Synthesize that map to services in your PSA.
#The function returns a list of properties needed to create the services, which includes "Total Agents," "Workstations," and "Servers."
#These properties are calculated based on the number of agents that had servers or workstations within the organization name, which were grouped and cleansed using the "Group-Organizations" function.

Function GetVendorServices
{
    Process {
        $propertiesToCreateServices = @(
        @{ Name = "Total Agents"; Description = "Managed EDR"; Category = "security"; Subcategory = "other" },
        @{ Name = "Workstations"; Description = "Managed EDR"; Category = "security"; Subcategory = "other" },
        @{ Name = "Servers"; Description = "Managed EDR"; Category = "security"; Subcategory = "other" }
        )
        return $propertiesToCreateServices
    }
}
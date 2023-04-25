function Invoke-SentinelOneAPI {
    # Function to invoke SentinelOne API
    param(
        [string]$Env:API_URL,
        [string]$Env:API_KEY,
        [string]$cursor = $null
    )

    # Create headers for the API request
    $headers = @{
        "Authorization" = "ApiToken $($Env:API_KEY)"
    }

    # Add the cursor parameter to the query if it's not null
    $stateParam = "state=active"
    $cursorParam = ""

    if ($cursor)
    {
        $encodedCursor = [System.Web.HttpUtility]::UrlEncode($cursor)
        $cursorParam = "&cursor=$encodedCursor"
    }

    $Uri = "$Env:API_URL/web/api/v2.1/sites?$stateParam$cursorParam"


    try
    {
        # Make the API request and return the response
        $response = Invoke-RestMethod -Method Get -Uri $Uri -Headers $headers
        # Write-Host "API Token Obtained. Successfully called SentinelOne API."
        return $response
    }
    catch
    {
        Write-Host "Error: $($_.Exception.Response.StatusCode.Value__) - $($_.Exception.Message)"
        throw "An error occurred while invoking SentinelOne API: $_"
    }
}

function Invoke-GetAccountSites {
    param (
        [string]$Env:API_URL,
        [string]$Env:API_KEY
    )

    # Call the function to retrieve all sites
    $sitesApiUrl = "$Env:API_URL/web/api/v2.1/sites?siteType=Paid&state=active"
    $sitesResponse = $null
    $cursor = $null

    # Initialize an empty hashtable to store the sites
    $sites = @{}

    do {
        $sitesResponse = Invoke-SentinelOneAPI -Uri $sitesApiUrl -ApiToken $Env:API_KEY -Cursor $cursor

        if ($sitesResponse) {
            # Add each site to the dictionary using the site ID as the key
            foreach ($site in $sitesResponse.data.sites) {
                $siteData = @{
                    "name"           = $site.name
                    "id"             = $site.id
                    "activelicenses" = $site.activeLicenses
                    "sku"            = $site.sku
                }
                $sites[$site.id] = $siteData
            }

            # Update the cursor for the next iteration
            $pagination = $sitesResponse.pagination
            $nextCursor = $pagination.nextCursor
            $cursor = $nextCursor
        }
    } while ($cursor)

    return $sites
}

Function GetVendorServices {
    Process {
        $propertiesToCreateServices = @(
        @{ Name = "Total Active Licenses"; Description = "Total active licenses"; Category = "security"; Subcategory = "endpoint detection and response (EDR)" },
        @{ Name = "Singularity Coplete"; Description = "Total active licenses for Core SKU"; Category = "security"; Subcategory = "endpoint detection and response (EDR)" },
        @{ Name = "Singularity Control"; Description = "Total active licenses for Control SKU"; Category = "security"; Subcategory = "endpoint detection and response (EDR)" },
        @{ Name = "Singularity Complete"; Description = "Total active licenses for Complete SKU"; Category = "security"; Subcategory = "endpoint detection and response (EDR)" }
        )
        return $propertiesToCreateServices
    }
}
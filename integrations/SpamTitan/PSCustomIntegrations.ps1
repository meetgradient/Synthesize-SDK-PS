# To create a new SpamTitan API token, you will need to follow these steps, or run New-SpamTitanToken

#Log in to your SpamTitan account.
#Go to the API Tokens section in the SpamTitan console.
#Click on the "Create" button to create a new token.
#Enter a name for your token in the "Token Name" field.
#Select the appropriate permissions for the token in the "Permissions" section.
#Click on the "Create" button to generate a new API token.
#Save the token somewhere secure, as you will not be able to view it again.
#Once you have created the token, you can use it to authenticate with the SpamTitan API and access the available endpoints. Please refer to the SpamTitan API documentation for further information on how to use the API with your newly created token.

function New-SpamTitanToken {
    param (
    )

    # Build the request body
    $body = @{
        email = $Env:USER
        password = $Env:USER_PASSWORD
    } | ConvertTo-Json

    # Send the API request to create the token
    $response = Invoke-RestMethod -Method Post -Uri "$($Env:BASE_URL)/auth/tokens" -Body $body

    # Get the new token value
    $newToken = $response.access_token

    # Output the new token
    Write-Output $newToken
}

function Set-SpamTitanHeaders {
    param ()

    $headers = @{
        'Authorization' = "Bearer $($Env:API_TOKEN)";
        'Accept' = 'application/json';
        'Content-Type' = 'application/json';
    }

    Write-Host $headers

    return $headers
}

function Get-SpamTitanDetails {
    param (
        [int]$DaysBack = 30
    )

    # Set headers
    $headers = Set-SpamTitanHeaders

    # Initialize hashtable
    $usage = @{}

    # Calculate date range
    $end_date = (Get-Date).AddDays(0).ToString("yyyy-MM-dd")
    $start_date = (Get-Date).AddDays(-$DaysBack).ToString("yyyy-MM-dd")

    # Retrieve domain groups
    $url = "$($Env:BASE_URL)/domain-groups"
    $groups_response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
    $groups = $groups_response.data

    if ($groups.Count -eq 0) {
        Write-Output "No domain groups found"
    } else {
        foreach ($group in $groups) {
            $group_id = $group.id
            $group_name = $group.name

            # Retrieve license usage for domain group and date range
            $url = "$($Env:BASE_URL)/reports/license-usage?start_date=$start_date&end_date=$end_date&domain_group_id=$($group_id.ToString())"
            $usage_response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
            $maximum = $usage_response.data.maximum

            # Add usage data to hashtable
            $data = @{
                "id" = $group_id
                "name" = $group_name
                "maximum" = $maximum
            }
            $usage[$group_id] = $data
        }
    }

    return $usage
}

Function GetVendorServices {
    Process {
        $propertiesToCreateServices = @(
        @{ Name = "Total Licenses"; Description = "Email Anti Spam & Security"; Category = "security"; Subcategory = "email security" }
   )
        return $propertiesToCreateServices
    }
}
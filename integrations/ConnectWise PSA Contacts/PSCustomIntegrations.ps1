function Invoke-ConnectWisePSA
{
    param (
    )

    # Concatenate company_id and public_key to form username
    $username = $Env:CUSTOMER_ID + '+' + $Env:PUBLIC_KEY
    # Concatenate username and private_key to form password
    $password = $Env:PRIVATE_KEY
    # Encode username:password in base64
    $auth_string = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($username + ':' + $password))

    # Set up headers for API request
    $headers = @{ Authorization = 'Basic ' + $auth_string }

    return $headers
}

function Get-ContactDetails
{
    param ()

    $contactTypes = @(
        'Billed User'
    )

    # Authenticate with ConnectWise PSA API
    $authorization = (Invoke-ConnectWisePSA).Authorization

    if (-not $authorization)
    {
        throw "Failed to generate authorization token"
    }

    $headers = @{
        'Authorization' = $authorization
        'clientId' = $Env:CLIENT_ID
        'pagination-type' = 'forward-only'
    }

    $response = @()
    $pageSize = 1000
    $pageId = 0

    # The loop will continue as long as the returned page contains records
    do
    {
        try
        {
            $uri = "$( $Env:BASE_URL )/v4_6_release/apis/3.0/company/contacts?pagesize=$pageSize&pageId=$pageId"
            $pageResponse = Invoke-RestMethod -Uri $uri -Method 'GET' -Headers $headers
            $response += $pageResponse

            Write-Host "Page response count: $($pageResponse.Count)"

            # Update pageId with the last ID from the fetched page
            if ($pageResponse)
            {
                $pageId = $pageResponse[-1].id
            }
        }
        catch
        {
            throw "An error occurred while making API request: $_"
        }
    }
    while ($pageResponse.Count -gt 0)

    if ($null -eq $response)
    {
        throw "The API request did not return a response"
    }

    # Creates a hashtable that stores the number of contacts for each type and company ID.
    $contactCountByCompanyAndType = @{}
    foreach ($contact in $response)
    {
        if ($contact.inactiveFlag -eq $false -and $contact.types.name -in $contactTypes)
        {
            if ($null -ne $contact.company -and $null -ne $contact.company.id)
            {
                $companyId = $contact.company.id.ToString()
                $companyName = $contact.company.name
                $contactType = $contact.types.name

                if ($contactCountByCompanyAndType.ContainsKey($companyId))
                {
                    if ($contactCountByCompanyAndType[$companyId]['contactTypes'].ContainsKey($contactType))
                    {
                        $contactCountByCompanyAndType[$companyId]['contactTypes'][$contactType] += 1
                    }
                    else
                    {
                        $contactCountByCompanyAndType[$companyId]['contactTypes'][$contactType] = 1
                    }
                }
                else
                {
                    $contactCountByCompanyAndType[$companyId] = @{
                        'id' = $companyId
                        'name' = $companyName
                        'contactTypes' = @{ $contactType = 1 }
                    }
                }
            }
        }
    }

    return $contactCountByCompanyAndType
}

function GetVendorServices
{
    Process {
        $services = @('Billed User')

        $propertiesToCreateServices = $services | ForEach-Object {
            @{
                'Name' = $_
                'Description' = "Total $_ Contacts"
                'Category' = 'other'
                'Subcategory' = 'other'
            }
        }

        return $propertiesToCreateServices
    }
}

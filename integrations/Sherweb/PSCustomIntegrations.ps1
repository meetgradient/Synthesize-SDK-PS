#The Invoke-SherwebAPI function sends a request to a Sherweb API endpoint, extracts an access token from the response, and sets headers for subsequent API calls.
function Invoke-SherwebAPI
{
    param (
    )

    # Define the request body as a hashtable
    $body = @{
        client_id = $Env:CLIENT_ID
        client_secret = $Env:CLIENT_SECRET
        scope = "service-provider"
        grant_type = "client_credentials"
    }

    $Uri = "$( $Env:BASE_URL )/auth/oidc/connect/token"

    # Send the request to the API endpoint and get the response as a JSON object
    $response = Invoke-RestMethod -Uri $Uri -Method Post -Body $body

    # Extract the access token from the response and store it in a variable
    $accessToken = $response.access_token

    # Set headers
    $headers = @{
        'Authorization' = "Bearer $accessToken";
        'Ocp-Apim-Subscription-Key' = $( $Env:SUBSCRIPTION_KEY );
        'Accept-Language' = 'en-US';
    }

    return $headers
}

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

#Get-Companies is a PowerShell function that retrieves a list of companies using the Sherweb API and converts the API response to a dictionary.
#The function is used in the Get-SubscriptionDetails function to retrieve the list of companies for which subscription details are to be retrieved.
#The dictionary returned by the Get-Companies function contains the company IDs and names and can be used to filter and sort the subscription details in a larger script or system.
function Get-Companies
{
    param (
    )

    $headers = Invoke-SherwebAPI

    # Retrieve a list of companies
    $companiesResponse = Invoke-ExponentialBackoff -Uri "$( $Env:BASE_URL )/service-provider/v1/customers" `
        -Method 'GET' `
        -Headers $headers

    $companiesResponseObject = $companiesResponse | ConvertFrom-Json

    $companies = @{ }

    Write-Host "Retrieving companies..."

    # Loop through each company and add its ID and name to the dictionary
    foreach ($item in $companiesResponseObject.items)
    {
        $id = $item.id
        $name = $item.displayName
        $companyData = @{
            "id" = $id
            "name" = $name
        }
        $companies[$id] = $companyData

        # Write-Host "Company ID: $( $companyData.id ) - Name: $( $companyData.name )"
    }

    Write-Host "Finished processing companies"

    return $companies
}

#Get-SubscriptionDetails is a PowerShell function that retrieves subscription details for each company using the Sherweb API and the Get-Companies function.
#The function simplifies the process of retrieving subscription details for each company and can be used as a building block for more complex scripts or systems.
function Get-SubscriptionDetails
{
    param (
    )

    $headers = Invoke-SherwebAPI

    # Call the Get-Companies function to retrieve the list of companies
    $companies = Get-Companies

    # Define a list to store subscription details for each company
    $subscriptionDetails = @()

    Write-Host "Retrieving subscriptions..."
    # Loop through each company and retrieve its subscriptions
    foreach ($company in $companies.Values)
    {
        # Define the API endpoint URL for the current company
        $uri = "$( $Env:BASE_URL )/service-provider/v1/billing/subscriptions?customerId=$( $company.id )"

        # Retrieve the subscriptions for the current company using Invoke-ExponentialBackoff
        $response = Invoke-ExponentialBackoff -Uri $uri -Method 'GET' -Headers $headers

        # Convert the response to JSON
        $responseJson = $response | ConvertFrom-Json

        # Loop through each subscription and retrieve its details
        foreach ($subscription in $responseJson.items)
        {
            $id = $subscription.id
            $productName = $subscription.productName
            $description = $subscription.description
            $sku = $subscription.sku
            $quantity = $subscription.quantity

            $subscriptionDetails += [ordered]@{
                "id" = $id
                "productName" = $productName
                "description" = $description
                "sku" = $sku
                "quantity" = $quantity
            }
        }
    }

    Write-Host "Finished processing subscriptions"
    return $subscriptionDetails
}

#Get-UniqueSubscriptions is a PowerShell function that creates a unique list of subscriptions based on the product name and SKU from a list of subscription details.
#The function removes duplicates and standardizes the subscription details, making it easier to work with in a larger system or script.
function Get-UniqueSubscriptions
{
    param (
    )

    $subscriptionDetails = Get-SubscriptionDetails

    # Initialize an empty array to store unique subscriptions
    $uniqueSubscriptions = @()

    # Loop through each subscription and extract its details
    foreach ($subscription in $subscriptionDetails)
    {
        Write-Host "Processing subscription: $( $subscription.productName ), SKU: $( $subscription.sku )"
        $subscriptionDetails = @{
            productName = $subscription.productName
            sku = $subscription.sku
        }

        # Check if the subscription already exists in the uniqueSubscriptions array
        $existingSubscription = $uniqueSubscriptions | Where-Object { $_.productName -eq $subscriptionDetails.productName -and $_.sku -eq $subscriptionDetails.sku }

        if (-not$existingSubscription)
        {
            # Add the subscription details to the uniqueSubscriptions array
            $uniqueSubscriptions += $subscriptionDetails
        }
    }

    # Sort the uniqueSubscriptions array by productName and sku, and remove duplicates
    $uniqueSubscriptions = $uniqueSubscriptions | Sort-Object productName, sku -Unique

    return $uniqueSubscriptions
}

#Get-VendorServices retrieves a unique list of subscriptions and creates an array of service properties to be used in a larger script or system.
#The service properties include information such as name, description, category, and subcategory, which can be used to categorize and organize the services provided by a vendor.
function Get-VendorServices
{
    param (
    )

    $uniqueSubscriptionDetails = Get-UniqueSubscriptions
    $uniqueSubscriptions = @{ }

    # Loop through each unique subscription
    foreach ($subscription in $uniqueSubscriptionDetails)
    {
        Write-Host "Processing unique subscription: $($subscription.productName), SKU: $($subscription.sku)"
        $subscriptionId = $subscription.sku

        if (-not $uniqueSubscriptions.ContainsKey($subscriptionId))
        {
            $uniqueSubscriptions[$subscriptionId] = $subscription
        }
    }

    $propertiesToCreateServices = @()

    foreach ($subscription in $uniqueSubscriptions.Values)
    {
        $subscriptionName = $subscription.productName.ToString()
        $subscriptionDescription = $subscription.description -ne $null ? $subscription.description.ToString() : ""

        $properties = @{
            Name = $subscriptionName
            Description = $subscriptionDescription
            Category = "productivity"
            Subcategory = "other"
        }
        $propertiesToCreateServices += ,($properties)
    }

    return $propertiesToCreateServices
}

#GetVendorServices is a wrapper function that takes the output of Get-VendorServices and transforms it into an array of service properties.
#The function simplifies the output of the Get-VendorServices function and standardizes the service properties by hard-coding the category and subcategory.
function GetVendorServices
{
    Process {
        $uniqueSubscriptionsProperties = Get-VendorServices
        $propertiesToCreateServices = @()

        foreach ($subscriptionProperties in $uniqueSubscriptionsProperties)
        {
            $propertiesToCreateServices += ,@{ Name = $subscriptionProperties.Name; Description = $subscriptionProperties.Description; Category = "productivity"; Subcategory = "other" }
        }

        return $propertiesToCreateServices
    }
}

#Get-Usage is a PowerShell function that retrieves usage details for each subscription of a company using Invoke-SherwebAPI and Invoke-ExponentialBackoff.
#The function retrieves a list of companies from the Sherweb API and creates a dictionary of company IDs and names.
#The function then loops through each company and retrieves its subscriptions, storing the details in a list of subscription details for each company.
#The subscription details include ID, product name, description, SKU, quantity, and customer ID.
#The function returns a dictionary containing the companies and their subscription details to the caller.
function Get-Usage {
    param (
    )

    $headers = Invoke-SherwebAPI

    # Retrieve a list of companies
    $companiesResponse = Invoke-ExponentialBackoff -Uri "$( $Env:BASE_URL )/service-provider/v1/customers" `
        -Method 'GET' `
        -Headers $headers

    $companiesResponseObject = $companiesResponse | ConvertFrom-Json

    $companies = @{ }

    Write-Host "Retrieving companies..."

    # Loop through each company and add its ID and name to the dictionary
    foreach ($item in $companiesResponseObject.items) {
        $id = $item.id
        $name = $item.displayName
        $companyData = @{
            "id" = $id
            "name" = $name
        }
        $companies[$id] = $companyData
    }

    Write-Host "Finished processing companies"

    # Define a list to store subscription details for each company
    $subscriptionDetails = @()

    Write-Host "Retrieving subscriptions..."
    # Loop through each company and retrieve its subscriptions
    foreach ($company in $companies.Values) {
        # Define the API endpoint URL for the current company
        $uri = "$( $Env:BASE_URL )/service-provider/v1/billing/subscriptions?customerId=$( $company.id )"

        # Retrieve the subscriptions for the current company using Invoke-ExponentialBackoff
        $response = Invoke-ExponentialBackoff -Uri $uri -Method 'GET' -Headers $headers

        # Convert the response to JSON
        $responseJson = $response | ConvertFrom-Json

        # Loop through each subscription and retrieve its details
        foreach ($subscription in $responseJson.items) {
            $id = $subscription.id
            $productName = $subscription.productName
            $description = $subscription.description
            $sku = $subscription.sku
            $quantity = $subscription.quantity

            $subscriptionDetails += [ordered]@{
                "id" = $id
                "productName" = $productName
                "description" = $description
                "sku" = $sku
                "quantity" = $quantity
                "customerId" = $company.id
            }
        }
    }

    Write-Host "Finished processing subscriptions"
    return @{
        "companies" = $companies
        "subscriptionDetails" = $subscriptionDetails
    }
}




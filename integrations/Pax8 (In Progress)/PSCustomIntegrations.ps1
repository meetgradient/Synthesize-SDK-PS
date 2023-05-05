function Connect-Pax8 {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Env:CLIENT_ID,
        [Parameter(Mandatory = $true)]
        [string]$Env:CLIENT_SECRET
    )

    $auth = @{
        client_id     = $Env:CLIENT_ID
        client_secret = $Env:CLIENT_SECRET
        audience      = "api://p8p.client"
        grant_type    = "client_credentials"
    }

    $json = $auth | ConvertTo-json -Depth 2

    try {
        $Response = Invoke-WebRequest -Method POST -Uri 'https://login.pax8.com/oauth/token' -ContentType 'application/json' -Body $json
        $Pax8Token = ($Response | ConvertFrom-Json).access_token
        return $Pax8Token
    } catch {
        Write-Host $_ -ForegroundColor Red
    }
}

function Get-Pax8Companies {
    [CmdletBinding()]
    Param()

    $Companies = Invoke-Pax8Request -method get -resource "companies"

    $CompanyList = @()

    foreach ($Company in $Companies) {
        $CompanyList += @{
            'id' = $Company.id
            'name' = $Company.name
        }
    }

    return $CompanyList
}

function Get-Pax8Subscriptions {
    [CmdletBinding()]
    Param()

    $Subscriptions = Invoke-Pax8Request -method get -resource "subscriptions"

    $subscriptionDetails = @()

    # Loop through each subscription and retrieve its details
    foreach ($subscription in $Subscriptions) {
        $id = $subscription.id
        $productName = $subscription.productName
        $description = $subscription.description
        $sku = $subscription.sku
        $quantity = $subscription.quantity
        $billingTerm = $subscription.billingTerm
        $commitmentTerm = $subscription.commitmentTerm

        $subscriptionDetails += [ordered]@{
            "id" = $id
            "productName" = $productName
            "description" = $description
            "sku" = $sku
            "quantity" = $quantity
            "billingTerm" = $billingTerm
            "commitmentTerm" = $commitmentTerm
        }
    }

    return $subscriptionDetails
}

function Get-UniqueSubscriptions {
    param ()

    $subscriptionDetails = Get-Pax8Subscriptions

    # Initialize an empty array to store unique subscriptions
    $uniqueSubscriptions = @()

    # Loop through each subscription and extract its details
    foreach ($subscription in $subscriptionDetails) {
        Write-Host "Processing subscription: $($subscription.productName), SKU: $($subscription.sku)"
        $subscriptionDetails = @{
            productName = "$($subscription.productName) $($subscription.billingTerm) $($subscription.commitmentTerm)"
            sku         = $subscription.sku
        }

        # Check if the subscription already exists in the uniqueSubscriptions array
        $existingSubscription = $uniqueSubscriptions | Where-Object { $_.productName -eq $subscriptionDetails.productName -and $_.sku -eq $subscriptionDetails.sku }

        if (-not $existingSubscription) {
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
        $subscriptionDescription = $null -ne $subscription.description ? $subscription.description.ToString() : ""

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

function Get-Usage {
    param (
    )

    Write-Host "Retrieving companies..."
    $companiesList = Get-Pax8Companies

    $companies = @{ }

    # Loop through each company and add its ID and name to the dictionary
    foreach ($company in $companiesList) {
        $id = $company.id
        $name = $company.name
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
        $subscriptions = Get-Pax8Subscriptions -companyId $company.id

        # Loop through each subscription and retrieve its details
        foreach ($subscription in $subscriptions) {
            $id = $subscription.id
            $productName = $subscription.productName
            $description = $subscription.description
            $sku = $subscription.sku
            $quantity = $subscription.quantity
            $billingTerm = $subscription.billingTerm
            $commitmentTerm = $subscription.commitmentTerm

            $subscriptionDetails += [ordered]@{
                "id" = $id
                "productName" = $productName
                "description" = $description
                "sku" = $sku
                "quantity" = $quantity
                "billingTerm" = $billingTerm
                "commitmentTerm" = $commitmentTerm
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
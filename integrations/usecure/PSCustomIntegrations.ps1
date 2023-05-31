function Test-usecureAPI {
    if ($null -eq $ENV:API_KEY) {
        throw 'API_KEY is required in .env'
    }
    if ($null -eq $ENV:API_URL) {
        throw 'API_URL is required in .env'
    }
}

function Invoke-usecureAPI {
    param(
        [string]$query
    )
    Begin {
        
    }
    Process {
        $RequestHeaders = @{
            'x-api-key' = $ENV:API_KEY
            'Content-Type' = 'application/json'
        }
        $RequestURI = $ENV:API_URL
        $RequestBodyJSON = @{
            query = $query
        } | ConvertTo-Json
        $response = Invoke-WebRequest -Uri $RequestURI -Headers $RequestHeaders -Body $RequestBodyJSON -Method 'POST' | ConvertFrom-Json
        return $response
    }
}

function Get-usecureClients {
    param()
    Process {
        $Accounts = @{}
        $Query = 'query { company { id, externalId, clients { name, id } } }'
        $APIResponse = Invoke-usecureAPI -query $Query 
        $AccountObjects = $APIResponse.data.company.clients
        foreach ($AccountObject in $AccountObjects) {
            $Account = @{
                id = $AccountObject.id
                name = $AccountObject.name
            }
            $Accounts[$AccountObject.id] = $Account
        }
        return $Accounts
    }
}

function Get-usecurePlans {
    Process {
        # There's no API for this, so we'll just return a static list.
        $Services = [System.Collections.Generic.List[Object]]::new()
        $ServicesList = @(
            @{
                Name = 'premium'
                Description = 'Subscribed with Domain Lock on and no expiration date.'
                Category = 'security'
                Subcategory = 'privacy and security awareness training'
            },
            @{
                Name = 'custom'
                Description = 'Subscribed with Domain Lock off.'
                Category = 'security'
                Subcategory = 'privacy and security awareness training'
            },
            @{
                Name = 'freeTrial'
                Description = 'Subscribed on a 2 week free trial.'
                Category = 'security'
                Subcategory = 'privacy and security awareness training'
            }
        )
        $Services.AddRange($ServicesList)
        return $Services # [{Name: "service-name", Description: "service-description", Category: ServiceCategoryEnum, Subcategory: ServiceSubCategoryEnum}]
    }
}

Function Get-usecureUsage {
    param(
        [string]$companyId
    )
    Process {
        $Query = "query { company(companyId: `"$companyId`") { plan { name, learnerCount, learnerLimit } } }"
        $APIResponse = Invoke-usecureAPI -query $Query
        $AccountUsage += $APIResponse.data.company.plan
        return $AccountUsage #Format is unique for each vendor, and how it is implemented in PSSyncUsage.ps1
    }
}
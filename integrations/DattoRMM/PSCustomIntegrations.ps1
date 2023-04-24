Function Invoke-AuthenticateVendorAPI {
    Process {
        $Authenticated = Invoke-GetApiAccessToken
        Write-Host $Authenticated
        return 0
    }
}

function Invoke-GetApiAccessToken {
    param (
    )
    Process {
        # Specify supported security protocols
        $supportedProtocols = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls

        # Set SecurityProtocol property to supported protocols
        [Net.ServicePointManager]::SecurityProtocol = $supportedProtocols

        # Convert password to secure string
        $securePassword = ConvertTo-SecureString -String 'public' -AsPlainText -Force

        # Define parameters for Invoke-WebRequest cmdlet
        $params = @{
            Credential  = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ('public-client', $securePassword)
            Uri         = '{0}/auth/oauth/token' -f $Env:API_URL
            Method      = 'POST'
            ContentType = 'application/x-www-form-urlencoded'
            Body        = 'grant_type=password&username={0}&password={1}' -f $Env:API_PUBLIC_KEY, $Env:API_SECRET_KEY
        }
        # Request access token
        try {
            $response = Invoke-WebRequest @params | ConvertFrom-Json
            return $response.access_token
        }
        catch {
            return @{
                Success       = $false
                ErrorMessage = $_.Exception.Message
            }
        }
    }

}


function Invoke-GetAccountSites {
    param(
    )

    $nextPageUrl = "$Env:API_URL/api/v2/account/sites"
    $sites = @()
    $retries = 0
    $maxRetries = 5
    $waitTime = 1
    $apiAccessToken = Invoke-GetApiAccessToken
    while ($nextPageUrl) {
        # Define parameters for Invoke-WebRequest cmdlet
        $params = @{
            Uri         = $nextPageUrl
            Method      = "GET"
            ContentType = "application/json"
            Headers     = @{
                'Authorization' = "Bearer $apiAccessToken"
            }
        }

        try {
            $response = Invoke-WebRequest @params | ConvertFrom-Json
            $sites += $response.sites
            $nextPageUrl = $response.pageDetails.nextPageUrl
            $retries = 0
        }
        catch {
            $retries++
            if ($retries -gt $maxRetries) {
                Write-Error "Error retrieving sites: $($_.Exception.Message)"
                Write-Host "API Response: $($_.Exception.Response)"
                return $null
            }
            else {
                Start-Sleep -Seconds $waitTime
                $waitTime *= 2
            }
        }
    }

    return $sites
}

Function GetVendorAccounts {
    Process {
        try {
            $Accounts = Invoke-GetAccountSites
            $AccountsDictionary = @{}
            foreach ($Account in $Accounts) {
#                Need to format accounts to be an object {name: 'Account Name', id: 123}
                $AccountData = @{
                    "name"           = $Account.name
                    "id"             = $Account.uid
                }
                $AccountsDictionary[[string]$Account.uid] = $AccountData
            }
            return $AccountsDictionary
        } catch {
            Write-Error $_
            throw 'An error occurred while getting vendor accounts. Script execution stopped.'
        }
    }
}

Function GetVendorServices {
    Process {
        $propertiesToCreateServices = @(
        @{ Name = "Total Devices"; Description = "Total Devices"; Category = "other"; Subcategory = "other" },
        @{ Name = "Total Online Devices"; Description = "Total Online Devices"; Category = "other"; Subcategory = "other" },
        @{ Name = "Desktops"; Description = "Total Desktops"; Category = "other"; Subcategory = "other" },
        @{ Name = "Laptops"; Description = "Total Laptops"; Category = "other"; Subcategory = "other" },
        @{ Name = "Servers"; Description = "Total Servers"; Category = "other"; Subcategory = "other" },
        @{ Name = "Total Workstations"; Description = "Total Workstations"; Category = "other"; Subcategory = "other" }
        )
        return $propertiesToCreateServices
    }
}


function Invoke-GetSiteDevices {
    param(
        [string]$siteUid
    )

    Process{
        $nextPageUrl = "$Env:API_URL/api/v2/site/$siteUid/devices"
        $devices = @()
        $retries = 0
        $maxRetries = 5
        $waitTime = 1
        $apiAccessToken = Invoke-GetApiAccessToken

        while ($nextPageUrl) {
            # Define parameters for Invoke-WebRequest cmdlet
            $params = @{
                Uri         = $nextPageUrl
                Method      = "GET"
                ContentType = "application/json"
                Headers     = @{
                    'Authorization' = "Bearer $apiAccessToken"
                }
            }

            try {
                $response = Invoke-WebRequest @params | ConvertFrom-Json
                $devices += $response.devices
                $nextPageUrl = $response.pageDetails.nextPageUrl
                $retries = 0
            }
            catch {
                Write-Error "Error getting devices trying again"
                $retries++
                if ($retries -gt $maxRetries) {
                    Write-Error "Error retrieving devices: $($_.Exception.Message)"
                    Write-Host "API Response: $($_.Exception.Response)"
                    return $null
                }
                else {
                    Start-Sleep -Seconds $waitTime
                    $waitTime *= 2
                }
            }
        }
        return $devices
    }
}
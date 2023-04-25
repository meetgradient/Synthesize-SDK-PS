# Add function to implement exponential backoff
function Invoke-RestMethodWithRetry {
    param (
        [Parameter(Mandatory = $true)] [hashtable] $Params,
        [int] $MaxRetries = 3,
        [int] $Delay = 1
    )

    $Attempt = 1
    while ($Attempt -le $MaxRetries) {
        try {
            return Invoke-RestMethod @Params
        }
        catch {
            $ErrorMessage = "Error in attempt ${Attempt}: $_"
            Write-Host $ErrorMessage -ForegroundColor Yellow

            if ($Attempt -eq $MaxRetries) {
                Write-Host "Max retries reached. Exiting." -ForegroundColor Red
                throw $ErrorMessage
            }

            $DelayInSeconds = [math]::Pow(2, $Attempt) * $Delay
            Write-Host "Waiting for $DelayInSeconds seconds before retrying" -ForegroundColor Yellow
            Start-Sleep -Seconds $DelayInSeconds
            $Attempt++
        }
    }
}

function Get-WebrootAccessToken {
    # Function to obtain Webroot Unity API access token
    param (
        [string]$Env:API_URL,
        [string]$Env:CLIENT_ID,
        [string]$Env:CLIENT_SECRET,
        [string]$Env:PARENT_KEY_CODE,
        [string]$Env:USER,
        [string]$Env:USERPASSWORD
    )

    # Obtain an access token
    $TokenEndpoint = "$Env:API_URL/auth/token"

    # Convert Rest Credentials to base64 string
    $Credentials = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Env:CLIENT_ID + ":" + $Env:CLIENT_SECRET))

    Write-Host "Processing access token" -ForegroundColor Green
    $Params = @{
        "ErrorAction" = "Stop"
        "URI"         = $TokenEndpoint
        "Headers"     = @{"Authorization" = "Basic " + $Credentials }
        "Body"        = @{
            "username"   = $Env:USER
            "password"   = $Env:USERPASSWORD
            "grant_type" = 'password'
            "scope"      = '*'
        }
        "Method"      = 'Post'
        "ContentType" = 'application/x-www-form-urlencoded'
    }

    try {
        $AccessToken = (Invoke-RestMethodWithRetry -Params $Params).access_token
        Write-Host "Access token successfully generated" -ForegroundColor Green
        return $AccessToken
    }
    catch {
        Write-Host "Error obtaining access token: $_" -ForegroundColor Red
        exit
    }
}

function Get-WebrootDetails {
    param (
    )

    # Get the access token
    $AccessToken = Get-WebrootAccessToken

    # Set date to yesterday
    $Yesterday = (Get-Date).AddDays(-2).ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ")

    # Get endpoints usage report
    Write-Host "Processing endpoints usage report" -ForegroundColor Green
    $EndpointReport = "$Env:API_URL/service/api/status/reporting/gsm/$Env:PARENT_KEY_CODE/sites?reportType=ActiveEndpoints&effectiveDate=$Yesterday"

    $Params = @{
        "ErrorAction" = "Stop"
        "URI" = $EndpointReport
        "ContentType" = "application/json"
        "Headers" = @{ "Authorization" = "Bearer " + $AccessToken }
        "Method" = "Get"
    }

    try
    {
        $AllEndpoints = (Invoke-RestMethodWithRetry -Params $Params)
        # Write-Host "AllEndpoints: $($AllEndpoints | ConvertTo-Json -Depth 3 -Compress)"
    }
    catch
    {
        Write-Host "Error obtaining list of endpoints: $_" -ForegroundColor Red
        exit
    }

    $EndpointInfoCollection = $AllEndpoints

    # Validate endpoint usage report
    if ($EndpointInfoCollection.Sites.Length -eq 0) {
        Write-Host "Endpoint usage report is empty." -ForegroundColor Yellow
    }

    # Get DNS Protection usage report
    Write-Host "Processing DNS Protection usage report" -ForegroundColor Green
    $DnsProtectionReportEndpoint = "$Env:API_URL/service/api/status/reporting/gsm/$Env:PARENT_KEY_CODE/sites/dnsp?reportType=DevicesSeen&effectiveDate=$Yesterday"

    $Params = @{
        "ErrorAction" = "Stop"
        "URI" = $DnsProtectionReportEndpoint
        "ContentType" = "application/json"
        "Headers" = @{ "Authorization" = "Bearer " + $AccessToken }
        "Method" = "Get"
    }

    try
    {
        $DnsProtectionReport = (Invoke-RestMethodWithRetry -Params $Params)
    }
    catch
    {
        Write-Host "Error obtaining DNS Protection usage report: $_" -ForegroundColor Red
        exit
    }

    $DnsProtectionCollection = $DnsProtectionReport
    # Write-Host "DnsProtectionReport: $($DnsProtectionReport | ConvertTo-Json -Depth 3 -Compress)"

    # Validate DNS Protection usage report
    if ($DnsProtectionCollection.Sites.Length -eq 0) {
        Write-Host "DNS Protection usage report is empty." -ForegroundColor Yellow
    }

    # Get WSAT usage report
    Write-Host "Processing WSAT usage report" -ForegroundColor Green
    $WsatReportEndpoint = "$Env:API_URL/service/api/status/reporting/gsm/$Env:PARENT_KEY_CODE/sites/wsat?reportType=UsersSeen&effectiveDate=$Yesterday"

    $Params = @{
        "ErrorAction" = "Stop"
        "URI" = $WsatReportEndpoint
        "ContentType" = "application/json"
        "Headers" = @{ "Authorization" = "Bearer " + $AccessToken }
        "Method" = "Get"
    }

    try
    {
        $WsatReport = (Invoke-RestMethodWithRetry -Params $Params)
    }
    catch
    {
        Write-Host "Error obtaining WSAT usage report: $_" -ForegroundColor Red
        exit
    }

    $WsatReportCollection = $WsatReport
    # Write-Host "WsatReport: $($WsatReport | ConvertTo-Json -Depth 3 -Compress)"

    # Validate WSAT usage report
    if ($WsatReportCollection.Sites.Length -eq 0) {
        Write-Host "WSAT usage report is empty." -ForegroundColor Yellow
    }

    # Combine the site objects into a unique list of sites
    $UniqueSites = ($EndpointInfoCollection.Sites + $DnsProtectionCollection.Sites + $WsatReportCollection.Sites) | Group-Object -Property SiteId, SiteName | ForEach-Object { $_.Group[0] }

    $SiteDictionary = @{}

    foreach ($site in $UniqueSites) {
        $siteId = $site.SiteId.ToString()
        $siteName = $site.SiteName

        $totalEndpoints = ($EndpointInfoCollection.Sites | Where-Object { $_.SiteId -eq $siteId }).TotalEndpoints
        $totalDNSPAgents = ($DnsProtectionCollection.Sites | Where-Object { $_.SiteId -eq $siteId }).TotalDNSPAgents
        $totalWSATUsers = ($WsatReportCollection.Sites | Where-Object { $_.SiteId -eq $siteId }).TotalWSATUsers

        $siteData = @{
            "name"                  = $siteName
            "id"                    = $siteId
            "TotalEndpoints"        = $totalEndpoints
            "TotalDNSPAgents"       = $totalDNSPAgents
            "TotalWSATUsers"        = $totalWSATUsers
        }

        $SiteDictionary[$siteId] = $siteData
    }
    return $SiteDictionary
}

Function GetVendorServices {
    Process {
        $propertiesToCreateServices = @(
        @{ Name = "Endpoint Protection"; Description = "Total active licenses"; Category = "security"; Subcategory = "endpoint detection and response (EDR)" },
        @{ Name = "DNS Protection"; Description = "Total active licenses for Core SKU"; Category = "security"; Subcategory = "DNS filtering" },
        @{ Name = "WSAT Webroot Security Awareness Training"; Description = "Total active licenses for Control SKU"; Category = "security"; Subcategory = "privacy and security awareness training" }
        )
        return $propertiesToCreateServices
    }
}
# Define the $headers variable for later use
function Get-AuvikApiToken
{
    $auvikApiUser = $Env:API_USER
    $auvikApiKey = $Env:API_KEY

    return @{
        "Authorization" = "Basic " + [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$auvikApiUser`:$auvikApiKey"))
    }
}

$headers = Get-AuvikApiToken

# Get Auvik Tenants
function Get-AuvikTenants {
    $headers = Get-AuvikApiToken
    Write-Host "Getting tenants..."
    $getAuvikTenants = "$( $Env:API_URL )/v1/tenants"
    $response = Invoke-WebRequest -Uri $getAuvikTenants -Headers $headers -Method Get
    try {
        if ($response.StatusCode -eq 200) {
            $responseData = $([System.Text.Encoding]::UTF8.GetString($response.Content)) | ConvertFrom-Json
            $tenants = @{}
            foreach ($tenant in $responseData.data) {
                $tenantId = $tenant.id
                $tenantName = $tenant.attributes.domainPrefix
                $tenants[$tenantId] = @{
                    "id" = $tenantId
                    "name" = $tenantName
                }
            }
            $tenantIds = ($responseData.data | Select-Object -ExpandProperty id) -join ","
            Write-Host "Tenant Ids: $tenantIds"
            return $tenants
        } else {
            throw "Error retrieving Auvik tenants: $( $response.StatusCode ) $( $response.StatusDescription )"
        }
    } catch {
        Write-Host "Error: $_"
    }
}

# Get Auvik Device Details
function Get-AuvikDeviceDetails {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$TenantId
    )

    $headers = Get-AuvikApiToken
    Write-Host "Getting device details for tenant $TenantId..."
    $deviceCounts = @{
        "Total Billable Devices" = 0
        "Firewalls"              = 0
        "Switches"               = 0
        "Controllers"            = 0
        "Layer 3 Switches"       = 0
        "VoIP Switches"          = 0
        "Switch Stacks"          = 0
        "Routers"                = 0
    }
    $deviceTypes = @("switch", "l3Switch", "router", "firewall", "voipSwitch", "stack", "controller")

    try {
        foreach ($deviceType in $deviceTypes) {
            $deviceDetailsApiUrl = "$($Env:API_URL)/v1/inventory/device/info?filter[deviceType]=$deviceType&tenants=$TenantId&include=deviceDetail"
            $response = Invoke-WebRequest -Uri $deviceDetailsApiUrl -Headers $headers -Method Get
            if ($response.StatusCode -eq 200) {
                $responseData = $([System.Text.Encoding]::UTF8.GetString($response.Content)) | ConvertFrom-Json
                if ($responseData -and $responseData.data) {
                    $devices = @()
                    foreach ($deviceDetail in $responseData.data) {
                        $devices += $deviceDetail
                    }

                    $deviceTypeKey = switch($deviceType) {
                        "switch" { "Switches" }
                        "l3Switch" { "Layer 3 Switches" }
                        "router" { "Routers" }
                        "firewall" { "Firewalls" }
                        "voipSwitch" { "VoIP Switches" }
                        "stack" { "Switch Stacks" }
                        "controller" { "Controllers" }
                        default { throw "Unexpected device type: $deviceType" }
                    }

                    $deviceCounts[$deviceTypeKey] = $devices.Count
                }
            }
        }

        # Calculate Total Billable Devices and Switches
        $deviceCounts['Total Billable Devices'] = $deviceCounts['Firewalls'] + $deviceCounts['Switches'] + $deviceCounts['Controllers'] + $deviceCounts['Routers']
        $deviceCounts['Total Switches'] = $deviceCounts['Switches'] + $deviceCounts['Layer 3 Switches'] + $deviceCounts['VoIP Switches'] + $deviceCounts['Switch Stacks']

        $deviceSummary += @{
            "TenantId" = $TenantId
            "DeviceCounts" = $deviceCounts
        }

        Write-Host "Device Counts: $($deviceCounts | ConvertTo-Json -Depth 2)"
        return $deviceCounts
    } catch {
        Write-Host "Error: $_"
    }
}

# Create Vendor Services for Billable Devices
Function GetVendorServices
{

    # What counts as a billable device in Auvik? https://support.auvik.com/hc/en-us/articles/203526850-What-counts-as-a-billable-device-

    Process {
        $propertiesToCreateServices = @(
        @{ Name = "Total Billable Devices"; Description = "Total Billable Devices"; Category = "infrastructure"; Subcategory = "network management and support" },
        @{ Name = "Firewalls"; Description = "Total firewall devices"; Category = "infrastructure"; Subcategory = "network management and support" },
        @{ Name = "Total Switches"; Description = "Total switch devices including Layer 3 switches, VoIP switches and switch stacks"; Category = "infrastructure"; Subcategory = "network management and support" },
        @{ Name = "Controllers"; Description = "Total controller devices"; Category = "infrastructure"; Subcategory = "network management and support" },
        @{ Name = "Layer 3 Switches"; Description = "Total layer 3 switches"; Category = "infrastructure"; Subcategory = "network management and support" },
        @{ Name = "VoIP Switches"; Description = "Total VoIP switches"; Category = "infrastructure"; Subcategory = "network management and support" },
        @{ Name = "Switch Stacks"; Description = "Total switch stacks"; Category = "infrastructure"; Subcategory = "network management and support" },
        @{ Name = "Routers"; Description = "Total routers"; Category = "infrastructure"; Subcategory = "network management and support" }
        )
        return $propertiesToCreateServices
    }
}
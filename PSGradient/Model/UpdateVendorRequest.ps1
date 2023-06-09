#
# API Documentation
# Howdy! Looks like you've found our open API documentation! Take a gander, and while you're at it feel free to take some endpoints for a spin.
# Version: 1.0
# Generated by OpenAPI Generator: https://openapi-generator.tech
#

<#
.SYNOPSIS

No summary available.

.DESCRIPTION

No description available.

.PARAMETER Name
No description available.
.PARAMETER Description
No description available.
.PARAMETER VendorSupportPageUrl
No description available.
.PARAMETER IntegrationPortalUrl
No description available.
.OUTPUTS

UpdateVendorRequest<PSCustomObject>
#>

function Initialize-PSUpdateVendorRequest {
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
        [String]
        ${Name},
        [Parameter(Position = 1, ValueFromPipelineByPropertyName = $true)]
        [String]
        ${Description},
        [Parameter(Position = 2, ValueFromPipelineByPropertyName = $true)]
        [String]
        ${VendorSupportPageUrl},
        [Parameter(Position = 3, ValueFromPipelineByPropertyName = $true)]
        [String]
        ${IntegrationPortalUrl}
    )

    Process {
        'Creating PSCustomObject: PSGradient => PSUpdateVendorRequest' | Write-Debug
        $PSBoundParameters | Out-DebugParameter | Write-Debug


        $PSO = [PSCustomObject]@{
            "name" = ${Name}
            "description" = ${Description}
            "vendorSupportPageUrl" = ${VendorSupportPageUrl}
            "integrationPortalUrl" = ${IntegrationPortalUrl}
        }


        return $PSO
    }
}

<#
.SYNOPSIS

Convert from JSON to UpdateVendorRequest<PSCustomObject>

.DESCRIPTION

Convert from JSON to UpdateVendorRequest<PSCustomObject>

.PARAMETER Json

Json object

.OUTPUTS

UpdateVendorRequest<PSCustomObject>
#>
function ConvertFrom-PSJsonToUpdateVendorRequest {
    Param(
        [AllowEmptyString()]
        [string]$Json
    )

    Process {
        'Converting JSON to PSCustomObject: PSGradient => PSUpdateVendorRequest' | Write-Debug
        $PSBoundParameters | Out-DebugParameter | Write-Debug

        $JsonParameters = ConvertFrom-Json -InputObject $Json

        # check if Json contains properties not defined in PSUpdateVendorRequest
        $AllProperties = ("name", "description", "vendorSupportPageUrl", "integrationPortalUrl")
        foreach ($name in $JsonParameters.PsObject.Properties.Name) {
            if (!($AllProperties.Contains($name))) {
                throw "Error! JSON key '$name' not found in the properties: $($AllProperties)"
            }
        }

        if (!([bool]($JsonParameters.PSobject.Properties.name -match "name"))) { #optional property not found
            $Name = $null
        } else {
            $Name = $JsonParameters.PSobject.Properties["name"].value
        }

        if (!([bool]($JsonParameters.PSobject.Properties.name -match "description"))) { #optional property not found
            $Description = $null
        } else {
            $Description = $JsonParameters.PSobject.Properties["description"].value
        }

        if (!([bool]($JsonParameters.PSobject.Properties.name -match "vendorSupportPageUrl"))) { #optional property not found
            $VendorSupportPageUrl = $null
        } else {
            $VendorSupportPageUrl = $JsonParameters.PSobject.Properties["vendorSupportPageUrl"].value
        }

        if (!([bool]($JsonParameters.PSobject.Properties.name -match "integrationPortalUrl"))) { #optional property not found
            $IntegrationPortalUrl = $null
        } else {
            $IntegrationPortalUrl = $JsonParameters.PSobject.Properties["integrationPortalUrl"].value
        }

        $PSO = [PSCustomObject]@{
            "name" = ${Name}
            "description" = ${Description}
            "vendorSupportPageUrl" = ${VendorSupportPageUrl}
            "integrationPortalUrl" = ${IntegrationPortalUrl}
        }

        return $PSO
    }

}


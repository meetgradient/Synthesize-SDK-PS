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

.PARAMETER MessageId
No description available.
.PARAMETER AlertId
No description available.
.PARAMETER CorrelationID
No description available.
.OUTPUTS

AlertCreatedDto<PSCustomObject>
#>

function Initialize-PSAlertCreatedDto {
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
        [String]
        ${MessageId},
        [Parameter(Position = 1, ValueFromPipelineByPropertyName = $true)]
        [String]
        ${AlertId},
        [Parameter(Position = 2, ValueFromPipelineByPropertyName = $true)]
        [String]
        ${CorrelationID}
    )

    Process {
        'Creating PSCustomObject: PSGradient => PSAlertCreatedDto' | Write-Debug
        $PSBoundParameters | Out-DebugParameter | Write-Debug

        if ($null -eq $MessageId) {
            throw "invalid value for 'MessageId', 'MessageId' cannot be null."
        }

        if ($null -eq $AlertId) {
            throw "invalid value for 'AlertId', 'AlertId' cannot be null."
        }

        if ($null -eq $CorrelationID) {
            throw "invalid value for 'CorrelationID', 'CorrelationID' cannot be null."
        }


        $PSO = [PSCustomObject]@{
            "messageId" = ${MessageId}
            "alertId" = ${AlertId}
            "correlationID" = ${CorrelationID}
        }


        return $PSO
    }
}

<#
.SYNOPSIS

Convert from JSON to AlertCreatedDto<PSCustomObject>

.DESCRIPTION

Convert from JSON to AlertCreatedDto<PSCustomObject>

.PARAMETER Json

Json object

.OUTPUTS

AlertCreatedDto<PSCustomObject>
#>
function ConvertFrom-PSJsonToAlertCreatedDto {
    Param(
        [AllowEmptyString()]
        [string]$Json
    )

    Process {
        'Converting JSON to PSCustomObject: PSGradient => PSAlertCreatedDto' | Write-Debug
        $PSBoundParameters | Out-DebugParameter | Write-Debug

        $JsonParameters = ConvertFrom-Json -InputObject $Json

        # check if Json contains properties not defined in PSAlertCreatedDto
        $AllProperties = ("messageId", "alertId", "correlationID")
        foreach ($name in $JsonParameters.PsObject.Properties.Name) {
            if (!($AllProperties.Contains($name))) {
                throw "Error! JSON key '$name' not found in the properties: $($AllProperties)"
            }
        }

        If ([string]::IsNullOrEmpty($Json) -or $Json -eq "{}") { # empty json
            throw "Error! Empty JSON cannot be serialized due to the required property 'messageId' missing."
        }

        if (!([bool]($JsonParameters.PSobject.Properties.name -match "messageId"))) {
            throw "Error! JSON cannot be serialized due to the required property 'messageId' missing."
        } else {
            $MessageId = $JsonParameters.PSobject.Properties["messageId"].value
        }

        if (!([bool]($JsonParameters.PSobject.Properties.name -match "alertId"))) {
            throw "Error! JSON cannot be serialized due to the required property 'alertId' missing."
        } else {
            $AlertId = $JsonParameters.PSobject.Properties["alertId"].value
        }

        if (!([bool]($JsonParameters.PSobject.Properties.name -match "correlationID"))) {
            throw "Error! JSON cannot be serialized due to the required property 'correlationID' missing."
        } else {
            $CorrelationID = $JsonParameters.PSobject.Properties["correlationID"].value
        }

        $PSO = [PSCustomObject]@{
            "messageId" = ${MessageId}
            "alertId" = ${AlertId}
            "correlationID" = ${CorrelationID}
        }

        return $PSO
    }

}


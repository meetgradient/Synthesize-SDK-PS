#
# API Documentation
# Howdy! Looks like you've found our open API documentation! Take a gander, and while you're at it feel free to take some endpoints for a spin.
# Version: 1.0
# Generated by OpenAPI Generator: https://openapi-generator.tech
#

<#
.Synopsis
    Helper function to get common parameters (Verbose, Debug, etc.)
.Example
    Get-CommonParameters
#>
function Get-CommonParameters {
    function tmp {
        [CmdletBinding()]
        Param ()
    }

    (Get-Command -Name tmp -CommandType Function).Parameters.Keys
}

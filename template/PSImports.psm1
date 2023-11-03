$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

$SdkDir = "${ScriptDir}\PSGradient"
Import-Module -Name $SdkDir
. "${ScriptDir}\PSInit.ps1"
. "${ScriptDir}\PSCreateAccountsFromVendor.ps1"
. "${ScriptDir}\PSCreateServicesFromVendor.ps1"
. "${ScriptDir}\PSSyncUsage.ps1"
. "${ScriptDir}\PSCustomIntegrations.ps1"
. "${SdkDir}\GradientHelpers\PSAuthenticate.ps1"
. "${SdkDir}\GradientHelpers\PSCreateAccounts.ps1"
. "${SdkDir}\GradientHelpers\PSCreateServices.ps1"
. "${SdkDir}\GradientHelpers\PSCreateServiceMappings.ps1"
. "${SdkDir}\GradientHelpers\PSUpdateIntegrationStatus.ps1"
. "${SdkDir}\GradientHelpers\PSInvokeGetServiceIds.ps1"
. "${SdkDir}\GradientHelpers\PSInvokeGetServiceMappingIds.ps1"
. "${SdkDir}\GradientHelpers\PSBuildGradientToken.ps1"
#Add other imports here
Get-Module
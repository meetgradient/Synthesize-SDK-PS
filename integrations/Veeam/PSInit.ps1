Function InitGradientConnection {
    Param(
        [String]
        $Command
    ) Process {

        If (“authenticate”, ”sync-accounts”, ”sync-services”, "update-status", "sync-usage" -NotContains $Command) {
            Throw “$Command is not a valid action! Please use authenticate, sync-accounts, sync-services, update-status, or sync-usage”
        }

        Get-Content "$ScriptDir\.env" | ForEach-Object {
        $name, $value = $_.split('=')

        if ([string]::IsNullOrWhiteSpace($name) -or $name.Contains('#')) {
            Write-Host "Omitting $name from ENV"
        } else {
            Set-Item -Path "env:$name" -Value $value
        }
    }

        If ([string]::IsNullOrWhiteSpace($Env:VENDOR_API_KEY) -OR [string]::IsNullOrWhiteSpace($Env:PARTNER_API_KEY) ) {
            Throw "Gradient API keys are required in ENV"
        }

        #Can add custom ENV validation here

        $GRADIENT_TOKEN = BuildGradientToken $Env:VENDOR_API_KEY $Env:PARTNER_API_KEY

        #Init SDK
        Set-PSConfiguration 'https://app.usegradient.com' '' '' @{
            'Gradient-Token' = $GRADIENT_TOKEN
        }
    }
}

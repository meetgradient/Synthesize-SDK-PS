$ScriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
Import-Module "${ScriptDir}\PSImports"

InitGradientConnection $args[0]
#Process Command
switch($args[0]){
    'sync-accounts' {Invoke-SyncAccounts; break}
    'sync-services' {Invoke-SyncServices; break}
    'update-status' {Invoke-UpdateStatus; break}
    'sync-usage' {Invoke-SyncUsage; break}
}
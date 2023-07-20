$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

Import-Module "${ScriptDir}\PSImports"
InitGradientConnection $args[0]
#Process Command
switch($args[0]){
    'authenticate' {Invoke-AuthenticateVendorAPI; break}
    'sync-accounts' {Invoke-SyncAccounts; break}
    'sync-services' {Invoke-SyncServices; break}
    'update-status' {Invoke-UpdateStatus; break}
    'sync-usage' {Invoke-SyncUsage; break}
}
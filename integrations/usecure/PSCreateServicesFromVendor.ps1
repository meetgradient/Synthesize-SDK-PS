Function Invoke-SyncServices {
    Param()
    Process {
        $Plans = Get-usecurePlans
        return Invoke-CreateServices $Plans 'https://meetgradient.com' 'phil.flamingo@meetgradient.com'
    }
}
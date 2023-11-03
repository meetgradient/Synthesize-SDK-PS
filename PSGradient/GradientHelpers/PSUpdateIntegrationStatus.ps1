Function Invoke-UpdateStatus {
    Param(
    ) Process {
        try {
            $integration = Get-PSIntegration
            if($integration.status -ne "active") {
                $response = Update-PSIntegrationStatus "pending"
            }
            Write-Host "Response  ${response}"
        } catch {
            Write-Error $_
            throw 'An error occurred while updating status. Script execution stopped.'
        }
    }
}

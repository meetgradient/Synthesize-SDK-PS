Function Invoke-UpdateStatus {
    Param(
    ) Process {
        try {
            $response = Update-PSIntegrationStatus "pending"
            Write-Host "Response  ${response}"
        } catch {
            Write-Error $_
            throw 'An error occurred while updating status. Script execution stopped.'
        }
    }
}

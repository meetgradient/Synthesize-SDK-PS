function global:Write-Host($message) {
    if($LambdaInput -and $LambdaContext) {
        $data = @{
            "organizationId" = $LambdaInput.body.organizationId
            "requestId"      = $LambdaContext.AwsRequestId
            "action"         = $LambdaInput.path.action
            #         Leaving this out as will log out sensitive creds
            #        "details"        = $_
            "message"        = $message
        }
        Write-Information (ConvertTo-Json -InputObject $data -Compress -Depth 3)
    } else {
        Write-Information $message
    }

}
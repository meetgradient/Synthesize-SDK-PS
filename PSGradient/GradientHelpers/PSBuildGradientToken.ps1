Function BuildGradientToken {
    Param(
        [String]
        $VendorApiKey,
        [string]
        $PartnerAPIKey
    ) Process {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes("${VendorApiKey}:${PartnerApiKey}")
        return [System.Convert]::ToBase64String($bytes)
    }
}

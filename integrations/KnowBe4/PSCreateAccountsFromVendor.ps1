Function Invoke-SyncAccounts {
    Param() Process {
        $GroupList = Get-KnowBe4Groups
        return Invoke-CreateAccounts $GroupList
    }
}


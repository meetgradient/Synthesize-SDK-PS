# Getting Started
## How to Obtain Secret API Key and Base URL
The Secret API key and Base URL are needed to populate the .env file, which contains environment variables to authenticate with KnowBe4 endpoints. The .env file should be kept secure and not shared in publicly-accessible areas.

### Base URL
When submitting API requests, you will need to use the correct base URL depending on where your KnowBe4 account is located:

- Accounts on the US server (located at training.knowbe4.com) must use the base URL of https://us.api.knowbe4.com.
- Accounts on the EU server (located at eu.knowbe4.com) must use https://eu.api.knowbe4.com.
- Accounts on the CA server (located at ca.knowbe4.com) must use https://ca.api.knowbe4.com.
- Accounts on the UK server (located at uk.knowbe4.com) must use https://uk.api.knowbe4.com.
- Accounts on the DE server (located at de.knowbe4.com) must use https://de.api.knowbe4.com.

### Secret API Key
You can access your API key and generate a new key if needed in your KnowBe4 Account Settings under the API section.

## Group Types in KnowBe4
Since there is no unique identifier for accounts in KnowBe4, the best way to structure groups per company is to allocate members or users to each group and filter by group type. This is typically done by MSPs, who create a group for each customer and bill based on the number of users or members in that particular group.

Filtering by group type is important to ensure that only the relevant groups are retrieved. For example, if an MSP is only interested in console groups, they can modify the Get-KnowBe4Groups function to only retrieve console groups, which can help streamline the data and improve performance.

There are three group types in KnowBe4:

- ***console_group***: Represents a group of users within the console.
- ***smart_group***: Represents a dynamic group that is automatically updated based on certain criteria.
- ***provisioning_managed_group***: Represents a group of users that is managed by the provisioning system.

## How to Filter by Group Type
By default, the Get-KnowBe4Groups function in the PSCustomIntegrations.ps1 module retrieves console group types.

To modify the Get-KnowBe4Groups function to filter by a different group type, follow these steps:

1. Open the PSCustomIntegrations.ps1 module  in your favorite text editor.
2. Locate the Get-KnowBe4Groups function.
3. Modify the line that filters the groups by status and group type by adding the desired group type to the condition. For example, to filter by console groups only, use the following condition:

```powershell
$ActiveConsoleGroups = $Response | Where-Object { $_.status -eq "active" -and $_.group_type -eq "console_group" }
```

4. Save the changes to the PSCustomIntegrations.ps1 module and continue with the deployment of the integration. The modified Get-KnowBe4Groups function will now retrieve the filtered groups based on the specified group type.
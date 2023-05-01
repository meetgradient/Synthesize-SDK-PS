# **Setting Up a Custom Integration in Synthesize with Gradient PowerShell SDK**
Welcome, fellow feathered friends! Are you ready to learn how to set up a custom integration in Synthesize using the Gradient PowerShell SDK? Let's get started!

This comprehensive guide explains the steps involved in setting up a custom integration in Synthesize using the Gradient PowerShell SDK. It covers the necessary steps to set up a project, implement some basic functions of the vendor and Synthesize API, and schedule the script to sync usage counts automatically.

## **Overview**
The project setup involves several steps, such as copying the sample environment (env) file, adding environment variables, and generating Gradient API tokens. After setting up the project, you need to implement some of the basic functions of the vendor API, such as invoking the vendor API, authenticating it, and getting vendor accounts and services.

Note that the Gradient Helpers are pre-built scripts that make the implementation of the vendor API easier. They help with authentication, creating accounts, creating services, getting service IDs, setting unit counts, and updating integration status.

## **Steps**

### **Step 1: Copy the Sample Environment (.env) File**
The first step is to copy the **sample env** file and rename it to **.env**. The **.env** file contains environment variables required for the project. You can modify these environment variables as per your requirements.

### **Step 2: Add Environment Variables**
The next step is to add environment variables to the **.env** file. You can refer to the vendor API documentation for further information on how to acquire vendor credentials.

To obtain the Gradient API tokens, follow these steps:

- [Login to Synthesize](https://app.usegradient.com/login)
- Navigate to Integrations
- Click the **Custom** button
- Choose the type of custom integration you would like to build (eg. Billing Only)
- Click **Generate API Tokens** to generate Vendor and Partner API Tokens
- Copy and save these tokens in a secure location, as they will be unavailable later and need to be regenerated if lost.
- Copy and paste the Vendor and Partner API tokens into environment variables in the **.env** file.

### **Step 3: Implement the Vendor API**
After setting up the environment variables, you need to implement the vendor API. The vendor API can be implemented using PowerShell. The following steps explain how to implement some of the basic functions of the vendor API:

#### **Invoke-VendorAPI**
The Invoke-VendorAPI function is used to invoke the vendor API. You need to add custom authentication, headers required for requests, or pagination to the function. Before calling the function, you need to validate the environment variables required for the API.

#### **AuthenticateVendorAPI**
The AuthenticateVendorAPI function is used to test authentication for the vendor API. You can use the Invoke-VendorAPI function to complete the request. You can test the implementation by running `pwsh -File "PSMain.ps1" authenticate`.

#### **Invoke-SyncAccounts**
The Invoke-SyncAccounts function is used to get all the accounts in the vendor, format them, and then return them. You can test the implementation by running `pwsh -File "PSMain.ps1" sync-accounts`.

#### **Invoke-SyncServices**
The Invoke-SyncServices function is used to get all the services for the vendor. Currently, only the name of the service is needed. Within PSCreateServicesFromVendor, the description, support URL, and contact can be updated. You can test the implementation by running `pwsh -File "PSMain.ps1" sync-services`.

#### **Invoke-UpdateStatus**
The Invoke-UpdateStatus function is used to update the integration status of an integration. It is required that you update the integration status to "pending" to map services in Synthesize.

### **Step 4: Map Accounts and Services in Synthesize**
After updating the integration status to "pending", log in to Synthesize and navigate to the custom integration you are implementing. You will be required to map accounts and services. If applicable, you can skip accounts and services and map multiple PSA products or services to a single SKU.

### **Step 5: Sync Usage**
The Invoke-SyncUsage function is used to set the unit count for each mapped account and service in Synthesize. This will set the unit count for each SKU or service created earlier in Synthesize.

Note that it is normal to encounter 404 errors when performing the Set unit count API call. Ensure that you handle this gracefully. This error will occur if a partner does not map all accounts and services that you provide. You cannot view their mappings, so always sync all information when syncing usage.

**Sample Response**

```
{
  "statusCode": 404,
  "message": "No account map found with id: 1"
}
```

### **Review and Approve Usage in Synthesize**
After setting unit counts and validating counts in Synthesize, you can review and approve updates, which will instantly write back to your PSA.

### **Schedule Script**
To automate the process of syncing usage counts, you can schedule the script to run on a weekly or monthly basis. Here are a few suggestions for scheduling a PowerShell script:

- Use Windows Task Scheduler to schedule the script to run at specific intervals.
- Use a third-party scheduling tool, such as Cron for Windows or Jenkins, to schedule the script.
- Set up the script to run automatically when the system starts up using PowerShell commands.

By scheduling the script to run automatically, you can ensure that your usage counts are synced regularly and accurately, without the need for manual intervention.

### **Conclusion**
Well, it looks like we've reached the end of our flight!

By following the steps outlined in this guide, you'll be soaring high with a custom integration in Synthesize using the Gradient PowerShell SDK.

Remember, these are just templates, so don't be afraid to ruffle some feathers and customize them to meet your specific needs. With the Gradient Helders and the Invoke-SyncUsage function, syncing usage counts will be as easy as a bird taking flight.

So, spread your wings and give it a try! You'll be amazed at how quickly you can set up an integration and implement the vendor API in your project. Happy flying!

### **Support**
If you have any questions or issues with the SDK, please contact support@usegradient.com.

### **Related Links**

- [Gradient website](https://www.meetgradient.com/)
- [Synthesize Login](https://app.usegradient.com/login)
- [Synthesize API documentation](https://api-docs.meetgradient.com/docs)
- [Synthesize Swagger documentation](https://www.example.com)

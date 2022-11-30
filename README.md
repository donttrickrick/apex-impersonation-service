

The project deploys with SFDX and CumulusCI. With any questions, please leave me a message or contact me at 18317028956@163.com or wechat: donttrickrick

> CumulusCI is the official Salesforce CI/CD OSS used by SFDO (salesforce.org) projects, eg. Nonprofits cloud and Education cloud.

## Steps: 

1. Preparation

- Checkout the source code in your local machine

- Install cumulusci; connect to your github account; the guide is here https://cumulusci.readthedocs.io/en/stable/get-started.html

>  Ensure that your github account is connected to your cumulusci. Otherwize you receive errors.

2. In your CLI, navigate to the project root folder, eg /~/projects/apex-impersonation-service/

3. Release package
```bash
cci flow run release_unlocked_beta --org beta
```
4. Deploy the source code to the scratch org
```bash
cci flow run ci_unlocked_beta --org beta
```
4. Open the scratch org
```bash
cci org browser beta
```
5. Manual configuration

    - Download certificates
    
        1. Setup -> Certificate and Key Management -> **MQCert_15April2022** -> **Download Certificate** and save it in your local folder
      
    - Update connected app

        1. Setup -> App Manager -> **Salesforce_Impersonater_Connected_App** -> Edit

        2. Tick **Use digital signatures** -> Upload the certificate **MQCert_15April2022** you saved before

        3. Setup -> App Manager -> **Salesforce_Impersonater_Connected_App** -> View -> Manage Consumer Details -> Copy Consumer Key
    
    - Update named credential
    
      1) Setup -> Named Credential -> **Salesforce_Impersonater** -> Paste the Consumer Key of **Salesforce_Impersonater_Connected_App** to the **Issuer** field

      2) Update the domain of **Url** and **Token Endpoint Url** to the domain of your scratch org. The domain is end with my.salesforce.com. For example, the correct **Url** should be in this format https://data-customization-1973-dev-ed.my.salesforce.com/; and the correct **Token Endpoint Url** should be in this format https://data-customization-1973-dev-ed.my.salesforce.com/services/oauth2/token
      
## Test:

The impersonator for testing is your scratch admin user. 

The imperosnated user for testing is "Apex Impersonation Service Test" user. (I suggest you changing this user's profile to "Minimum Access - Salesforce" profile which minimize the effection of non-related permissions.)

The test classes are in scripts/apex/demo-1.apex and scripts/apex/demo-2.apex. You can use them to play around.

## Demos:

https://medium.com/@rick.xyz.yang/impersonate-users-in-salesforce-ea7010aab7a8

// 2) Grant and revoke "Impersonate" permission
// Before runing the code, please revoke Custom_Permission_Feature_Impersonate_Salesforce from admin, then grant Custom_Permission_Feature_Impersonate_Salesforce_Session_Enabled to admin
System.debug('1. expect failure becaused session based permission set has not been activiated');

new Impersonation().run();

public class Impersonation {
    public void run() {
        User theUser = [
            SELECT Id, Username 
            FROM User 
            WHERE 
                IsActive = true 
                AND Email = 'apex.impersonation.service.test@nomail.com'
        ];
        try {
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setMethod('GET');
            httpRequest.setHeader('Content-Type', 'application/json;charset=UTF-8');
    
            new NamedCredentialClient(
                'callout:Salesforce_Impersonater/services/data/v48.0/tooling/executeAnonymous?anonymousBody='
                + EncodingUtil.urlEncode('System.debug(String.format(\'Current User Email is {0}\',new List<Object>{UserInfo.getUserEmail()}));', 'UTF-8'),
                NamedCredentialClient.Mode.ENHANCED_PER_USER_IMPERSONATE,
                new SalesforceImpersonater(theUser.Username)
            ).send(httpRequest);

        } catch(Exception e) {
            System.debug('Failure:' + e.getMessage());
        }
    }
}


System.debug('2.1 admin self activiation');
User adminUser = [
    SELECT Id, Username 
    FROM User 
    WHERE 
        IsActive = true 
        AND Email = '18317028956@163.com'
];
SessionBasedPermissionSetService.activatePermissionSetForCurrentUser('Custom_Permission_Feature_Impersonate_Salesforce_Session_Enabled');


System.debug('2.2 expect success after activiation');


System.debug('3.1 admin self deactiviation');
User adminUser = [
    SELECT Id, Username 
    FROM User 
    WHERE 
        IsActive = true 
        AND Email = '18317028956@163.com'
];
SessionBasedPermissionSetService.deactivatePermissionSetForCurrentUser('Custom_Permission_Feature_Impersonate_Salesforce_Session_Enabled');

System.debug('3.2 expect failure again after deactiviation');

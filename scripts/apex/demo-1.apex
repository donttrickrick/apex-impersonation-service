// 1) admin 18317028956@163.com impersonates the user apex.impersonation.service.test@nomail.com
System.debug(String.format('Main transaction Starts. The current user context is {0}, Email {1}', new List<Object> {
    UserInfo.getUserName(), UserInfo.getUserEmail()
}));


User theUser = [
    SELECT Username 
    FROM User 
    WHERE 
        IsActive = true 
        AND Email = 'apex.impersonation.service.test@nomail.com'
];

HttpRequest httpRequest = new HttpRequest();
httpRequest.setMethod('GET');
httpRequest.setHeader('Content-Type', 'application/json;charset=UTF-8');

new NamedCredentialClient(
    'callout:Salesforce_Impersonater/services/data/v48.0/tooling/executeAnonymous?anonymousBody='
    + EncodingUtil.urlEncode('System.debug(String.format(\'Child transaction Starts. The current user context is {0} Email {1}\', new List<Object> { UserInfo.getUserName(), UserInfo.getUserEmail() }));', 'UTF-8'),
    NamedCredentialClient.Mode.ENHANCED_PER_USER_IMPERSONATE,
    new SalesforceImpersonater(theUser.Username)
).send(httpRequest);
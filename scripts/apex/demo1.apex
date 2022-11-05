
System.debug(String.format('Main transaction Starts. The current user context is {1}', new List<Object> {
    UserInfo.getUserName()
}));


String theImpersonatedUsername = 'apex.impersonate.service.1@nomail.com';

HttpRequest httpRequest = new HttpRequest();
httpRequest.setMethod('POST');
httpRequest.setHeader('Content-Type', 'application/json;charset=UTF-8');

new NamedCredentialClient(
    'callout:Salesforce_Impersonate/services/data/v48.0/tooling/executeAnonymous?anonymousBody='
    + 'System.debug(String.format(\'Child transaction Starts. The current user context is {1}\', new List<Object> { UserInfo.getUserName()}));',
    NamedCredentialClient.Mode.ENHANCED_PER_USER_IMPERSONATE,
    new SalesforceImpersonater(theImpersonatedUsername)
).send(httpRequest);


// NamedCredentialClient namedCredentialClient = new NamedCredentialClient(
//     'callout:Salesforce_Impersonater/services/apexrest/v1.0/executeAnonymous',
//     NamedCredentialClient.Mode.ENHANCED_PER_USER_IMPERSONATE,
//     new SalesforceImpersonater(theUser.Username)
// );
// HttpResponse httpResp = namedCredentialClient.send(httpRequest);

// System.debug();
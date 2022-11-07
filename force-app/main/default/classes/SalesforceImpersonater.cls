// https://digi-trade.atlassian.net/browse/CRM-319
public with sharing class SalesforceImpersonater implements Impersonateable {
    private String subject;

    public SalesforceImpersonater(String subject) {
        this.subject = subject;
    }

    public String mintToken() {
        if(!FeatureManagement.checkPermission('Feature_Impersonate_Salesforce')) {
            throw new SalesforceImpersonaterException('You don\'t have permission to mint a Salesforce token.');
        }

        NamedCredential mqNamedCredential = [
            SELECT JwtIssuer, JwtFormulaSubject, JwtTextSubject, JwtValidityPeriodSeconds, JwtAudience, AuthTokenEndpointUrl, Id, DeveloperName, Endpoint, PrincipalType, AuthProviderId 
            FROM NamedCredential 
            WHERE DeveloperName = 'Salesforce_Impersonater' 
            LIMIT 1
        ];
        String certificationName = String.valueOf(Environment_Variable__c.getInstance().SF_Impersonater_Certification_Name__c);

        Auth.JWT jwt = new Auth.JWT();
        jwt.setSub(this.subject); 
        jwt.setAud(mqNamedCredential.JwtAudience.removeStart('"').removeEnd('"')); 
        jwt.setIss(mqNamedCredential.JwtIssuer);
        
        //Additional claims to set scope
        // Map<String, Object> claims = new Map<String, Object>();
        // claims.put('scope', '');
            
        // jwt.setAdditionalClaims(claims);

        //Create the object that signs the JWT bearer token
        Auth.JWS jws = new Auth.JWS(jwt, certificationName);
        
        //Get the resulting JWS in case debugging is required
        String token = jws.getCompactSerialization();
        
        //Set the token endpoint that the JWT bearer token is posted to
        String tokenEndpoint = mqNamedCredential.AuthTokenEndpointUrl;
        
        //POST the JWT bearer token
        Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(tokenEndpoint, jws);
        
        //Get the access token
        String accessToken = bearer.getAccessToken();

        return accessToken;
    }

    public class SalesforceImpersonaterException extends Exception {}
}
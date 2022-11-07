public with sharing class NamedCredentialClient {
    private String endpoint;
    // https://digi-trade.atlassian.net/browse/CRM-312
    private Mode mode = NamedCredentialClient.Mode.BY_DEFAULT;
    private Impersonateable impersonater;

    public NamedCredentialClient(String endpoint) {
        this.endpoint = endpoint;
    }
    // https://digi-trade.atlassian.net/browse/CRM-312
    public NamedCredentialClient(String endpoint, Mode mode) {
        this.endpoint = endpoint;
        this.mode = mode;
    }
    // https://digi-trade.atlassian.net/browse/CRM-312
    public NamedCredentialClient(String endpoint, Mode mode, Impersonateable impersonater) {
        this.endpoint = endpoint;
        this.mode = mode;
        this.impersonater = impersonater;
    }

    public Mode getMode() {
        return this.mode;
    }

    public HttpResponse send(HttpRequest request) {
        Http http = new HTTP();
        HttpResponse response = new HttpResponse();
        NamedCredential namedCredential = null;
        if(this.mode == NamedCredentialClient.Mode.ENHANCED_PER_USER) {
            
            String[] endpointPath = endpoint.removeStartIgnoreCase('callout:').split('/');
            if(endpointPath.size() > 0) {
                List<NamedCredential> namedCredentialList = [
                    SELECT Id, Endpoint, DeveloperName, AuthProviderId
                    FROM NamedCredential 
                    WHERE DeveloperName = :endpointPath[0]
                ];
                if(namedCredentialList.size() > 0) {
                    namedCredential = namedCredentialList[0];

                    this.endpoint = namedCredential.Endpoint.removeEndIgnoreCase('/')
                                + endpoint.removeStartIgnoreCase('callout:' + namedCredential.DeveloperName);
                }
            }
            if(namedCredential == null) {
                throw new NamedCredentialClientException('The named credential doesn\'t exsit.');
            }
            String accessToken = Auth.AuthToken.getAccessToken(namedCredential.AuthProviderId, 'Open ID Connect'); // currently only support this one

            if(String.isBlank(accessToken)) {
                throw new NamedCredentialClientException('The user doesn\'t have access token. Please ask the user to login to consent.');
            }

            System.debug('***namedCredential.AuthProviderId: ' + namedCredential.AuthProviderId);
            CommonService.logLongText('***accessToken', accessToken);
            // system.debug(Pattern.compile('(.{299})').matcher(accessToken).replaceAll('$1\n'));

            request.setEndpoint(this.endpoint);
            request.setHeader('Authorization', 'Bearer ' + accessToken);
            
            response = http.send(request);

            if(response.getStatusCode() == 401) {
                Map<String, String> refreshAccessTokenMap = Auth.AuthToken.refreshAccessToken(namedCredential.AuthProviderId, 'Open ID Connect', accessToken); // currently only support this one
                accessToken = refreshAccessTokenMap.get('AccessToken');

                System.debug('***refreshAccessTokenMap: ' + refreshAccessTokenMap);

                request.setHeader('Authorization', 'Bearer ' + accessToken);
                response = http.send(request);
            }
            System.debug('***response.getBody(): ' + response.getBody());
        } else if(this.mode == NamedCredentialClient.Mode.BY_DEFAULT) {
            request.setEndpoint(this.endpoint);
            response = http.send(request);
            System.debug('***response.getBody(): ' + response.getBody());
        } else if(this.mode == NamedCredentialClient.Mode.ENHANCED_PER_USER_IMPERSONATE) { // https://digi-trade.atlassian.net/browse/CRM-319
            
            String[] endpointPath = endpoint.removeStartIgnoreCase('callout:').split('/');
            if(endpointPath.size() > 0) {
                List<NamedCredential> namedCredentialList = [
                    SELECT Id, Endpoint, DeveloperName, AuthProviderId
                    FROM NamedCredential 
                    WHERE DeveloperName = :endpointPath[0]
                ];
                if(namedCredentialList.size() > 0) {
                    namedCredential = namedCredentialList[0];

                    this.endpoint = namedCredential.Endpoint.removeEndIgnoreCase('/')
                                + endpoint.removeStartIgnoreCase('callout:' + namedCredential.DeveloperName);
                }
            }
            if(namedCredential == null) {
                throw new NamedCredentialClientException('The named credential doesn\'t exsit.');
            }

            String sessionId = this.impersonater.mintToken();

            request.setEndpoint(this.endpoint);
            request.setHeader('Authorization', 'Bearer ' + sessionId);

            response = http.send(request);
            System.debug('***response.getBody(): ' + response.getBody());

        }

        return response;
    }
    
    public enum Mode {
        BY_DEFAULT,
        ENHANCED_PER_USER,
        ENHANCED_PER_USER_IMPERSONATE // https://digi-trade.atlassian.net/browse/CRM-319
    }

    public class NamedCredentialClientException extends Exception {}
}
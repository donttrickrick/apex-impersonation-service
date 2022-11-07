// https://digi-trade.atlassian.net/browse/CRM-312
@RestResource(urlMapping='/v1.0/executeAnonymous')
global with sharing class ExecuteAnonymousRestService {
    @HttpPost
    global static ResponseWrapper doPost() {
        ResponseWrapper resWrapper = new ResponseWrapper();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            String requestBody = req.requestBody.toString();

            RequestWrapper wrapper = (RequestWrapper)System.JSON.deserialize(requestBody, RequestWrapper.class);

            Type theType = Type.forName(wrapper.callableApexClass);
            Callable callableApex = (Callable)theType.newInstance();
            Object result = callableApex.call(wrapper.callableAction, (Map<String, Object>)JSON.deserializeUntyped(wrapper.callableArgs));

            resWrapper.success = true;
            resWrapper.result = JSON.serialize(result);
            res.statusCode = 200;

        } catch(Exception e) {
            resWrapper.success = false;
            resWrapper.errorMessage = String.join(new List<String> {
                e.getMessage(),
                e.getStackTraceString() 
            }, '\n');
            res.statusCode = 400;
        }
        return resWrapper;
    }

    public class RequestWrapper {
        public String callableApexClass;
        public String callableAction;
        public String callableArgs;
    }

    global virtual class ResponseWrapper {
        public Boolean success;
        public String errorMessage;
        public String result;
    }
}
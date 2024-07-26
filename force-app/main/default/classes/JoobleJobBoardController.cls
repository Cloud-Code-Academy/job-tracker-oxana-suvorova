public with sharing class JoobleJobBoardController {

    @AuraEnabled
    public static String getNewJobPositions(String keywords, String location){
        try {
            Map<String, String> paramsMap = new Map<String, String>();
            paramsMap.put('keywords', keywords);
            paramsMap.put('location', location);
            String params = JSON.serialize(paramsMap);
            
            HttpResponse response = makeCallout(params);
            JoobleWrapper jobWrap = (JoobleWrapper) JSON.deserialize(response.getBody(), JoobleWrapper.class);
            System.debug(jobWrap);

            return String.valueOf(response.getStatusCode());

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static HttpResponse makeCallout(String params) {
        HTTP http = new HTTP();
        HTTPRequest request = new HTTPRequest();
        request.setEndpoint('callout:JoobleJobBoard');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(params);
        HttpResponse response = http.send(request);

        return response;
    }
}
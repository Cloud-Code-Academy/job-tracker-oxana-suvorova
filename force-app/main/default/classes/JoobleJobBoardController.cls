public with sharing class JoobleJobBoardController {

    @AuraEnabled
    public static List<JoobleWrapper.JoobleJob> getNewJobPositions(String keywords, String location){
        try {
            List<JoobleWrapper.JoobleJob> newJobs = new List<JoobleWrapper.JoobleJob>();

            Map<String, String> paramsMap = new Map<String, String>();
            paramsMap.put('keywords', keywords);
            paramsMap.put('location', location);
            String params = JSON.serialize(paramsMap);
            
            HttpResponse response = makeCallout(params);
            if (response.getStatusCode() == 200) {
                JoobleWrapper jobWrap = JoobleWrapper.parse(response.getBody());
                newJobs = jobWrap.jobs;
            }

            return newJobs;

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
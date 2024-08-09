/**
* JoobleJobBoardCalloutMock class description:
*
* Used by JoobleJobBoardControllerTest test class as a mock for HTTP callouts to the JoobleJobBoard service.
* This mock simulates the positive case.
 */
@isTest
public class JoobleJobBoardCalloutMock implements HttpCalloutMock {

    public static final String JOOBLE_PAYLOAD = '{"totalCount":12507,"jobs":[{"title":"Salesforce Admin/Developer","location":"Boston, MA","snippet":"JOB TITLE: <b>Salesforce </b>Admin/<b>Developer </b> Do you have the skills to fill this role Read the complete details below, and make your application today.  JOB LOCATION: Boston MA  WAGE RANGE*: 80-85 JOB NUMBER: Client-25-1030-0P100-0P110-105276 REQUIRED EXPERIENCE:·...&nbsp;","salary":"","source":"joblookup.com","type":"","link":"https://jooble.org/desc/742818580865934041?ckey=Salesforce+developer&rgn=22682&pos=1&groupId=40906&elckey=-4203833401212070862&p=1&aq=-2289814852444632785&cid=3590&jobAge=297&relb=175&brelb=115&bscr=7850.8887&scr=11947.00454347826","company":"The Computer Merchant, LTD.","updated":"2024-07-20T00:00:00.0000000","id":742818580865934100}]}';

    public HTTPResponse respond(HTTPRequest req) {
        Assert.areEqual('POST', req.getMethod(), 'This class send a mock response only for POST method');
        // Create a fake response
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application/json; charset=utf-8');
        res.setBody(JOOBLE_PAYLOAD);
        res.setStatusCode(200);
        return res;
    }
}
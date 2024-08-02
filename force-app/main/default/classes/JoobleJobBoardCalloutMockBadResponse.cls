/**
* JoobleJobBoardCalloutMockException class description:
*
* Used by JoobleJobBoardControllerTest test class as a mock for HTTP callouts to the JoobleJobBoard service.
* This mock simulates the negative case.
 */
@isTest
public class JoobleJobBoardCalloutMockBadResponse implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {
        Assert.areEqual('POST', req.getMethod(), 'This class send a mock response only for POST method');
        // Create a fake 'Bad Request' response
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'text/html');
        res.setStatusCode(400);
        res.setStatus('Bad request');
        return res;
    }
}
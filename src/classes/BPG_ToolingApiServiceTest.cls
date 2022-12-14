@IsTest
private class BPG_ToolingApiServiceTest {
    private static final BPG_TestDataService.SObjectCreator RecordCreator = new BPG_TestDataService.SObjectCreator();

    @IsTest
    private static void itShouldReturnApiQueryResultsOnGet() {
        BPG_CalloutMockService calloutMockService = new BPG_CalloutMockService();
        calloutMockService.setIgnoreQuery(false).setReturnAny(true);
        calloutMockService.addMock('http://test.mock.com/?q=SELECT+Id+FROM+Flow+LIMIT+1', new SuccessQueryMockCallout());

        BPG_ToolingApiService apiService = new BPG_ToolingApiService();
        apiService.setSessionId(UserInfo.getSessionId());
        apiService.setApiVersion('44.0');

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, calloutMockService);
            HttpResponse r1 = apiService.query('?q=SELECT+Id+FROM+Flow+LIMIT+1');
            System.assertEquals(200, r1.getStatusCode());

            List<BPG_ToolingApiObjects.Flow> data = (List<BPG_ToolingApiObjects.Flow>)apiService.getRecords(List<BPG_ToolingApiObjects.Flow>.class, r1.getBody());
            System.assertEquals(1, data.size());
    }

    @IsTest
    private static void itShouldReturnApiQueryResultsOnPost() {
        BPG_CalloutMockService calloutMockService = new BPG_CalloutMockService();
        calloutMockService.setIgnoreQuery(false).setReturnAny(true);
        calloutMockService.addMock('http://test.mock.com/?q=SELECT+Id+FROM+Flow+LIMIT+1', new SuccessQueryMockCallout());

        BPG_ToolingApiService apiService = new BPG_ToolingApiService();
        apiService.setSessionId(UserInfo.getSessionId());
        apiService.setApiVersion('44.0');

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, calloutMockService);
            HttpResponse r1 = apiService.callout('?q=SELECT+Id+FROM+Flow+LIMIT+1', 'POST', '{}');
            System.assertEquals(200, r1.getStatusCode());

            List<BPG_ToolingApiObjects.Flow> data = (List<BPG_ToolingApiObjects.Flow>)apiService.getRecords(List<BPG_ToolingApiObjects.Flow>.class, r1.getBody());
            System.assertEquals(1, data.size());
    }

    @IsTest
    private static void itShouldReturnErrorWithMessageList() {
        BPG_CalloutMockService calloutMockService = new BPG_CalloutMockService();
        calloutMockService.setIgnoreQuery(false).setReturnAny(true);
        calloutMockService.addMock('http://test.mock.com/?q=SELECT+Id+FROM+Flow+LIMIT+1', new ErrorQueryMockCallout());

        BPG_ToolingApiService apiService = new BPG_ToolingApiService();
        apiService.setSessionId(UserInfo.getSessionId());

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, calloutMockService);

            try {
                HttpResponse r1 = apiService.query('?q=SELECT+Id+FROM+Flow+LIMIT+1');
                System.assert(false);
            } catch(BPG_ToolingApiService.ApiException ex) {
                System.assertEquals('Status Code: 400 \nStatus: ERROR\nSession is invalid for this api call', ex.getMessage());
            }
    }

    @IsTest
    private static void itShouldReturnApiObjects() {
        Test.startTest();

            BPG_ToolingApiObjects.FlowApexTestStats apexTestStats = new BPG_ToolingApiObjects.FlowApexTestStats();
            apexTestStats.Id = RecordCreator.generateId(Schema.ApexComponent.getSObjectType());
            apexTestStats.ApexTestClassId = RecordCreator.generateId(Schema.ApexClass.getSObjectType());
            apexTestStats.ApexTestClass = new BPG_ToolingApiObjects.ApexClass();
            apexTestStats.ApexTestClass.Name = 'Test';
            apexTestStats.TestMethodName = 'TestMethod';
            apexTestStats.NumElementsCovered = 8;
            apexTestStats.NumElementsNotCovered = 2;

            System.assertEquals(80, apexTestStats.PercentCovered * 100);
            System.assertEquals('TestMethod', apexTestStats.TestMethodName);

            BPG_ToolingApiObjects.Flow flow = new BPG_ToolingApiObjects.Flow();
            flow.VersionNumber = 12;
            flow.Description = 'Test';
            flow.MasterLabel = 'Test';
            flow.ProcessType = 'Workflow';
            flow.Status = 'Active';
            flow.Definition = new BPG_ToolingApiObjects.FlowDefinition();
            flow.Definition.MasterLabel = 'Test';
            flow.Definition.DeveloperName = 'Test';

            apexTestStats.FlowVersion = flow;

            System.assertEquals('Test', apexTestStats.MasterLabel);
            System.assertEquals('Workflow', apexTestStats.ProcessType);
            System.assertEquals('Test', apexTestStats.ApexClass);
            System.assertEquals(12, apexTestStats.VersionNumber);
    }

    public class SuccessQueryMockCallout implements BPG_CalloutMockService.IMockResponse {

        public HttpResponse getResponse(HttpRequest req) {
            HttpResponse response = new HttpResponse();
            response.setStatus('SUCCESS');
            response.setStatusCode(200);

            String body = '{'
             + '"size": 1,'
             + '"totalSize": 1,'
             + '"done": true,'
             + '"queryLocator": null,'
             + '"entityTypeName": "Flow",'
             + '"records": ['
             +   '{'
             +     '"attributes": {'
             +       '"type": "Flow",'
             +       '"url": "/services/data/v44.0/tooling/sobjects/Flow/3010O000000QHPKQA4"'
             +     '},'
             +     '"Id": "3010O000000QHPKQA4",'
             +     '"Definition": {'
             +       '"attributes": {'
             +         '"type": "FlowDefinition",'
             +         '"url": "/services/data/v44.0/tooling/sobjects/FlowDefinition/3000O0000000GyGQAU"'
             +       '},'
             +       '"DeveloperName": "C4E_Case_Approved_Actions"'
             +     '},'
             +     '"MasterLabel": "C4E Case Closed Actions",'
             +     '"ProcessType": "Workflow",'
             +     '"VersionNumber": 4'
             +   '}'
             + ']'
            + '}';

            response.setBody(body);
            return response;
        }

        public String getMethod() {
            return 'GET';
        }
    }

    public class ErrorQueryMockCallout implements BPG_CalloutMockService.IMockResponse {

        public HttpResponse getResponse(HttpRequest req) {
            HttpResponse response = new HttpResponse();
            response.setStatus('ERROR');
            response.setStatusCode(400);

            String body = '['
                + '{'
                +    '"message": "Session is invalid for this api call"'
                + '}'
            + ']';

            response.setBody(body);
            return response;
        }

        public String getMethod() {
            return 'GET';
        }
    }
}
@IsTest
private class BPG_FlowCoverageControllerTest {
    private static final BPG_TestDataService.SObjectCreator RecordCreator = new BPG_TestDataService.SObjectCreator();

    @IsTest
    private static void itShouldReturnPageData() {
        BPG_CalloutMockService calloutMockService = new BPG_CalloutMockService();
        calloutMockService.setReturnAny(true);

        calloutMockService.addMock('https://test.salesforce.com', new TotalActiveFlowsMock())
                .addMock('https://test.salesforce.com', new TotalCoveredFlowsMock())
                .addMock('https://test.salesforce.com', new TotalNotCoveredFlowsMock());

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, calloutMockService);
            Map<String, Object> response = BPG_FlowCoverageController.getPageRequestData();

            System.assertEquals(7, response.values().size());
            System.assertEquals(100, (Integer)response.get('FlowCoverage'));
    }

    @IsTest
    private static void itShouldReturnErrorOnPageData() {
        BPG_CalloutMockService calloutMockService = new BPG_CalloutMockService();
        calloutMockService.setReturnAny(true);

        calloutMockService.addMock('https://test.salesforce.com', new ApiErrorMock());

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, calloutMockService);

            try {
                Map<String, Object> response = BPG_FlowCoverageController.getPageRequestData();
                System.assert(false);
            } catch(System.AuraHandledException ex) {
                System.assert(true);
            }
    }

    @IsTest
    private static void itShouldReturnElementsCoverage() {
        BPG_CalloutMockService calloutMockService = new BPG_CalloutMockService();
        calloutMockService.setReturnAny(true);

        calloutMockService.addMock('https://test.salesforce.com', new ElementCoverageDetailsMock());

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, calloutMockService);
            Map<String, Object> response = BPG_FlowCoverageController.getTestCoverageElements('FlowTestCoverage', RecordCreator.generateId(Schema.Account.getSObjectType()));
            List<BPG_ToolingApiObjects.FlowElementTestCoverage> data = (List<BPG_ToolingApiObjects.FlowElementTestCoverage>)response.get('ElementCoverage');

            System.assertEquals(1, data.size());
    }

    @IsTest
    private static void itShouldReturnErrorOnElementsCoverage() {
        BPG_CalloutMockService calloutMockService = new BPG_CalloutMockService();
        calloutMockService.setReturnAny(true);

        calloutMockService.addMock('https://test.salesforce.com', new ApiErrorMock());

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, calloutMockService);

            try {
                Map<String, Object> response = BPG_FlowCoverageController.getTestCoverageElements('FlowTestCoverage', RecordCreator.generateId(Schema.Account.getSObjectType()));
                System.assert(false);
            } catch (System.AuraHandledException ex) {
                System.assert(true);
            }
    }

    @IsTest
    private static void itShouldReturnApexFlowStats() {
        BPG_CalloutMockService calloutMockService = new BPG_CalloutMockService();
        calloutMockService.setReturnAny(true);

        calloutMockService.addMock('https://test.salesforce.com', new ApexFlowStatsMock());

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, calloutMockService);
            Map<String, Object> response = BPG_FlowCoverageController.getApexTestCoverageStats();
            List<Object> flowMenu = (List<Object>)response.get('FlowMenuItems');
            Map<Id, List<Object>> flowItemMap = (Map<Id, List<Object>>)response.get('FlowItemsMap');

            System.assertEquals(false, flowMenu.isEmpty());
            System.assertEquals(false, flowItemMap.isEmpty());
    }

    @IsTest
    private static void itShouldReturnErrorOnApexFlowStats() {
        BPG_CalloutMockService calloutMockService = new BPG_CalloutMockService();
        calloutMockService.setReturnAny(true);

        calloutMockService.addMock('https://test.salesforce.com', new ApiErrorMock());

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, calloutMockService);

            try {
                Map<String, Object> response = BPG_FlowCoverageController.getApexTestCoverageStats();
                System.assert(false);
            } catch (System.AuraHandledException ex) {
                System.assert(true);
            }
    }

    @IsTest
    private static void itShouldReturnFlowCoverage() {
        BPG_CalloutMockService calloutMockService = new BPG_CalloutMockService();
        calloutMockService.setReturnAny(true);

        calloutMockService.addMock('https://test.salesforce.com', new GetFlowCoverageMock());

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, calloutMockService);
            List<BPG_FlowCoverageController.CoverageResult> data = BPG_FlowCoverageController.getFlowCoverage(new List<String>{'Test'});

            System.assertEquals(1, data.size());
    }

    @IsTest
    private static void itShouldReturnFailSilentlyOnFlowCoverage() {
        BPG_CalloutMockService calloutMockService = new BPG_CalloutMockService();
        calloutMockService.setReturnAny(true);

        calloutMockService.addMock('https://test.salesforce.com', new ApiErrorMock());

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, calloutMockService);
            List<BPG_FlowCoverageController.CoverageResult> data = BPG_FlowCoverageController.getFlowCoverage(new List<String>{'Test'});

            System.assertEquals(true, data.isEmpty());
    }

    public class ApiErrorMock implements BPG_CalloutMockService.IMockResponse {

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

    public class TotalActiveFlowsMock implements BPG_CalloutMockService.IMockResponse {

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

    public class TotalCoveredFlowsMock implements BPG_CalloutMockService.IMockResponse {

        public HttpResponse getResponse(HttpRequest req) {
            HttpResponse response = new HttpResponse();
            response.setStatus('SUCCESS');
            response.setStatusCode(200);

            String body = '{'
            + '"size": 1,'
            + '"totalSize": 1,'
            + '"done": true,'
            + '"queryLocator": null,'
            + '"entityTypeName": "AggregateResult",'
            + '"records": ['
            +    '{'
            +      '"attributes": {'
            +        '"type": "AggregateResult"'
            +      '},'
            +      '"MasterLabel": "C4E Case Closed Actions",'
            +      '"expr0": "C4E_Case_Approved_Actions",'
            +      '"NumElementsCovered": 4,'
            +      '"NumElementsNotCovered": 6,'
            +      '"VersionNumber": 4,'
            +      '"FlowId": "3010O000000QHPKQA4",'
            +      '"ProcessType": "Workflow"'
            +    '}'
            +  ']'
            + '}';

            response.setBody(body);
            return response;
        }

        public String getMethod() {
            return 'GET';
        }
    }

    public class TotalNotCoveredFlowsMock implements BPG_CalloutMockService.IMockResponse {

        public HttpResponse getResponse(HttpRequest req) {
            HttpResponse response = new HttpResponse();
            response.setStatus('SUCCESS');
            response.setStatusCode(200);

            String body = '{'
            +  '"size": 1,'
            +  '"totalSize": 1,'
            +  '"done": true,'
            +  '"queryLocator": null,'
            +  '"entityTypeName": "Flow",'
            +  '"records": ['
            +    '{'
            +      '"attributes": {'
            +        '"type": "Flow",'
            +        '"url": "/services/data/v44.0/tooling/sobjects/Flow/3010O000000QHPNQA4"'
            +      '},'
            +      '"Id": "3010O000000QHPNQA4",'
            +      '"Definition": {'
            +        '"attributes": {'
            +          '"type": "FlowDefinition",'
            +          '"url": "/services/data/v44.0/tooling/sobjects/FlowDefinition/3000O0000000GyIQAU"'
            +        '},'
            +        '"DeveloperName": "C4E_Create_Case"'
            +      '},'
            +      '"MasterLabel": "C4E Create Case",'
            +      '"ProcessType": "AutoLaunchedFlow",'
            +      '"VersionNumber": 1'
            +    '}'
            +  ']'
            + '}';

            response.setBody(body);
            return response;
        }

        public String getMethod() {
            return 'GET';
        }
    }

    public class ElementCoverageDetailsMock implements BPG_CalloutMockService.IMockResponse {

        public HttpResponse getResponse(HttpRequest req) {
            HttpResponse response = new HttpResponse();
            response.setStatus('SUCCESS');
            response.setStatusCode(200);

            String body = '{'
            +  '"size": 1,'
            +  '"totalSize": 1,'
            +  '"done": true,'
            +  '"queryLocator": null,'
            +  '"entityTypeName": "AggregateResult",'
            +  '"records": ['
            +    '{'
            +      '"attributes": {'
            +        '"type": "AggregateResult",'
            +        '"url": "/services/data/v44.0/tooling/sobjects/AggregateResult/3031l0000032jx7AAA"'
            +      '},'
            +      '"ElementName": "eventcontextcheckdecision",'
            +      '"Id": "3031l0000032jx7AAA",'
            +      '"ApexClass": "C4E_DeploymentStatusTest",'
            +      '"TestMethodName": "itShouldNotCreateDeploymentLogRecordFromOtherSObject"'
            +    '}'
            +   ']'
            +  '}';

            response.setBody(body);
            return response;
        }

        public String getMethod() {
            return 'GET';
        }
    }

    public class ApexFlowStatsMock implements BPG_CalloutMockService.IMockResponse {

        public HttpResponse getResponse(HttpRequest req) {
            HttpResponse response = new HttpResponse();
            response.setStatus('SUCCESS');
            response.setStatusCode(200);

            response.setBody([SELECT Body FROM StaticResource WHERE Name = 'BPG_FlowApexTestStatsMock'].Body.toString());
            return response;
        }

        public String getMethod() {
            return 'GET';
        }
    }

    public class GetFlowCoverageMock implements BPG_CalloutMockService.IMockResponse {

        public HttpResponse getResponse(HttpRequest req) {
            HttpResponse response = new HttpResponse();
            response.setStatus('SUCCESS');
            response.setStatusCode(200);

            String body = '{'
            +  '"size": 1,'
            +  '"totalSize": 1,'
            +  '"done": true,'
            +  '"queryLocator": null,'
            +  '"entityTypeName": "AggregateResult",'
            +  '"records": ['
            +    '{'
            +      '"attributes": {'
            +        '"type": "AggregateResult"'
            +      '},'
            +      '"DeveloperName": "C4E_Deployment_Status",'
            +      '"NumElementsCovered": 7,'
            +      '"NumElementsNotCovered": 1,'
            +      '"VersionNumber": 7,'
            +      '"FlowId": "3011l0000005Aj6AAE",'
            +      '"ProcessType": "CustomEvent"'
            +    '}'
            +  ']'
            + '}';

            response.setBody(body);
            return response;
        }

        public String getMethod() {
            return 'GET';
        }
    }
}
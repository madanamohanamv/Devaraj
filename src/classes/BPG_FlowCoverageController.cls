/*
* The class provides methods to capture flow analytics and flow apex test stats.
* To deploy a process or flow as active, your org must have 75% flow test coverage. To calculate your org’s
* flow test coverage, Salesforce divides the number of covered flows and processes by the sum of the number of
* active processes and active auto launched flows.
*/
global class BPG_FlowCoverageController {

    @TestVisible
    private static BPG_ToolingApiService ToolingService = new BPG_ToolingApiService();

    @TestVisible
    private static final String SessionId = (Test.isRunningTest() ? UserInfo.getSessionId() : Page.BPG_SessionId.getContent().toString().trim());

    /*
    * This method returns the summarised flow test coverage for all active flows.
    * This includes the total active flows, total flows covered, total flows not covered and
    * overall flow percentage.
    */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getPageRequestData() {
        Map<String, Object> response = new Map<String, Object>();

        try {
            ToolingService.setSessionId(SessionId);
            Object queryResult = null;

            //Get total active flows.
            HttpResponse res = ToolingService.query('SELECT Id, Definition.DeveloperName, MasterLabel, ProcessType, VersionNumber '
                                                    + 'FROM Flow WHERE Status = \'Active\' '
                                                            + 'AND (ProcessType = \'AutolaunchedFlow\' OR ProcessType = \'Workflow\' OR '
                                                                        + 'ProcessType = \'CustomEvent\' OR ProcessType = \'InvocableProcess\') '
                                                    + 'ORDER BY MasterLabel ASC');

            queryResult = ToolingService.getRecords(List<BPG_ToolingApiObjects.Flow>.class, res.getBody());
            List<BPG_ToolingApiObjects.Flow> totalFlowCoverageResults = (List<BPG_ToolingApiObjects.Flow>)queryResult;
            Decimal totalFlows = totalFlowCoverageResults.size();

            //Get total covered flows.
            res = ToolingService.query('SELECT FlowVersion.MasterLabel MasterLabel, MAX(FlowVersion.Definition.DeveloperName), '
                                            + 'MAX(NumElementsCovered) NumElementsCovered, '
                                            + 'MIN(NumElementsNotCovered) NumElementsNotCovered, '
                                            + 'MAX(FlowVersion.VersionNumber) VersionNumber, '
                                            + 'MAX(FlowVersion.Id) FlowId, '
                                            + 'MAX(FlowVersion.ProcessType) ProcessType '
                                        + 'FROM FlowTestCoverage '
                                        + 'GROUP BY FlowVersion.MasterLabel '
                                        + 'ORDER BY FlowVersion.MasterLabel ASC');

            queryResult = ToolingService.getRecords(List<BPG_ToolingApiObjects.FlowCoverageResult>.class, res.getBody());
            List<BPG_ToolingApiObjects.FlowCoverageResult> coveredFlowCoverageResults = (List<BPG_ToolingApiObjects.FlowCoverageResult>)queryResult;
            Decimal coveredFlows = coveredFlowCoverageResults.size();

            //Get total **NOT** covered flows.
            res = ToolingService.query('SELECT Id, Definition.DeveloperName, MasterLabel, ProcessType, VersionNumber FROM Flow '
                                        + 'WHERE Status = \'Active\' AND (ProcessType = \'AutolaunchedFlow\' ' +
                                                + 'OR ProcessType = \'Workflow\' OR ProcessType = \'CustomEvent\' '
                                                + 'OR ProcessType = \'InvocableProcess\') '
                                        + 'AND Id NOT IN (SELECT FlowVersionId FROM FlowTestCoverage) '
                                        + 'ORDER BY MasterLabel ASC');

            queryResult = ToolingService.getRecords(List<BPG_ToolingApiObjects.Flow>.class, res.getBody());
            List<BPG_ToolingApiObjects.Flow> noFlowCoverageResults = (List<BPG_ToolingApiObjects.Flow>)queryResult;
            Decimal notCoveredFlows = noFlowCoverageResults.size();

            //Summarised properties for flow coverage.
            response.put('TotalActiveFlows', totalFlows.intValue());
            response.put('TotalActiveRecords', totalFlowCoverageResults);

            response.put('TotalCoveredFlows', coveredFlows.intValue());
            response.put('TotalCoveredRecords', coveredFlowCoverageResults);

            response.put('TotalNotCoveredFlows', notCoveredFlows.intValue());
            response.put('TotalNotCoveredRecords', noFlowCoverageResults);

            response.put('FlowCoverage', (totalFlows > 0 ? (coveredFlows.divide(totalFlows, 2) * 100).intValue() : 0));

        } catch (System.Exception ex) {
            new BPG_AuraHandledException().setMessage(ex).throwException();
        }

        return response;
    }

    /*
    * Returns individual or group element coverage details. Main interest here is which element name/node got tested.
    * @param type - the grouping type FlowTestCoverage|FlowVersionCoverage
    * @param targetId - the grouping type FlowTestCoverageId|FlowVersionId
    */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getTestCoverageElements(String type, Id targetId) {
        Map<String, Object> response = new Map<String, Object>();

        try {
            ToolingService.setSessionId(SessionId);
            Object queryResult = null;

            //This can probably be refactored to pass in only the targetId and then do grouping mapping?
            HttpResponse res = ToolingService.query('SELECT ElementName, MAX(Id) Id, MAX(FlowTestCoverage.ApexTestClass.Name) ApexClass, '
                                                    + 'MAX(FlowTestCoverage.TestMethodName) TestMethodName '
                                                    + 'FROM FlowElementTestCoverage '
                                                    + (type == 'FlowTestCoverage' ? 'WHERE FlowTestCoverageId = \''
                                                            + targetId + '\' ' : 'WHERE FlowVersionId = \'' + targetId + '\' ')
                                                    + 'GROUP BY ElementName');

            queryResult = ToolingService.getRecords(List<BPG_ToolingApiObjects.FlowElementTestCoverage>.class, res.getBody());
            List<BPG_ToolingApiObjects.FlowElementTestCoverage> flowElementTestCoverage = (List<BPG_ToolingApiObjects.FlowElementTestCoverage>)queryResult;
            response.put('ElementCoverage', flowElementTestCoverage);

        } catch (System.Exception ex) {
            new BPG_AuraHandledException().setMessage(ex).throwException();
        }

        return response;
    }

    /*
    * Returns apex test stats for each flow, which apex class and test method contributed to flow coverage.
    */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getApexTestCoverageStats() {
        Map<String, Object> response = new Map<String, Object>();

        try {
            ToolingService.setSessionId(SessionId);

            Object queryResult = null;
            List<Object> flowMenu = new List<Object>();
            Map<Id, List<Object>> flowItemMap = new Map<Id, List<Object>>();

            //Get apex test coverages for flows.
            HttpResponse res = ToolingService.query('SELECT Id, ApexTestClass.Name, ApexTestClassId, TestMethodName, FlowVersionId, '
                                                        + 'FlowVersion.Definition.DeveloperName, FlowVersion.MasterLabel, '
                                                        + 'FlowVersion.VersionNumber, NumElementsCovered, NumElementsNotCovered, '
                                                        + 'FlowVersion.ProcessType '
                                                    + 'FROM FlowTestCoverage '
                                                    + 'ORDER BY FlowVersion.Masterlabel ASC, ApexTestClass.Name ASC, TestMethodName ASC');

            queryResult = ToolingService.getRecords(List<BPG_ToolingApiObjects.FlowApexTestStats>.class, res.getBody());
            List<BPG_ToolingApiObjects.FlowApexTestStats> flowApexTestStats = (List<BPG_ToolingApiObjects.FlowApexTestStats>)queryResult;

            for (BPG_ToolingApiObjects.FlowApexTestStats item :flowApexTestStats) {

                //We want to group each flow by all flow test coverage.
                if (!flowItemMap.containsKey(item.FlowVersionId)) {

                    //Create object structure for flow menu.
                    Map<String, Object> flow = new Map<String, Object>();
                    flow.put('Label', item.MasterLabel);
                    flow.put('Value', item.FlowVersionId);
                    flowMenu.add(flow);

                    flowItemMap.put(item.FlowVersionId, new List<Object>());
                }

                //Grouping is related to flow menu via flow version id.
                flowItemMap.get(item.FlowVersionId).add(item);
            }

            response.put('FlowMenuItems', flowMenu);
            response.put('FlowItemsMap', flowItemMap);

        } catch (System.Exception ex) {
            new BPG_AuraHandledException().setMessage(ex).throwException();
        }

        return response;
    }

    /*
    * This method returns a list of flow test coverage stats for particular flows.
    * This should mainly be used in process flows or normal flows to get summary
    * details on the current flow coverage.
    *
    * @param flowDeveloperNames - a list of flow developer names to get test coverage detail for
    */
    @InvocableMethod(label='Get Flow Coverage' description='Returns a list of flow coverage stats.')
    global static List<CoverageResult> getFlowCoverage(List<String> flowDeveloperNames) {
        List<CoverageResult> response = new List<CoverageResult>();

        try {
            ToolingService.setSessionId(SessionId);

            //Get total covered flows.
            HttpResponse res = ToolingService.query('SELECT FlowVersion.Definition.DeveloperName, '
                                                        + 'MAX(NumElementsCovered) NumElementsCovered, '
                                                        + 'MIN(NumElementsNotCovered) NumElementsNotCovered, '
                                                        + 'MAX(FlowVersion.VersionNumber) VersionNumber, '
                                                        + 'MAX(FlowVersion.Id) FlowId, '
                                                        + 'MAX(FlowVersion.ProcessType) ProcessType '
                                                    + 'FROM FlowTestCoverage '
                                                    + 'WHERE FlowVersion.Definition.DeveloperName IN '
                                                            + '(' + '\'' + String.join(flowDeveloperNames, '\', \'') + '\'' + ') '
                                                    + 'GROUP BY FlowVersion.Definition.DeveloperName '
                                                    + 'ORDER BY FlowVersion.Definition.DeveloperName ASC');

            Map<String, Object> data = (Map<String, Object>)System.JSON.deserializeUntyped(res.getBody());

            //Iterate through the list of records returned from the tooling api response.
            for (Object item :(List<Object>)data.get('records')) {

                //Convert to consumable object and use wrapper object.
                response.add(new CoverageResult((Map<String, Object>)item));
            }
        } catch(System.Exception ex) {
            System.debug(ex);
        }

        return response;
    }

    global class CoverageResult {
        @InvocableVariable
        public Id FlowId;
        @InvocableVariable
        public Integer NumElementsCovered;
        @InvocableVariable
        public Integer NumElementsNotCovered;
        @InvocableVariable
        public Integer TotalElements;
        @InvocableVariable
        public Integer PercentCovered;

        public CoverageResult(Map<String, Object> coverage) {
            FlowId = (Id)coverage.get('FlowId');
            NumElementsCovered = (Integer)coverage.get('NumElementsCovered');
            NumElementsNotCovered = (Integer)coverage.get('NumElementsNotCovered');
            TotalElements = NumElementsCovered + NumElementsNotCovered;
            PercentCovered = (TotalElements > 0 ? (((Decimal)NumElementsCovered).divide(TotalElements, 2) * 100).intValue() : 0);
        }
    }
}
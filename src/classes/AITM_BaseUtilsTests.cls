@IsTest 
private class AITM_BaseUtilsTests {

    public static final String VALUE_TYPE_DATE = 'DATE';
    private static final String TENDER_LOCATION_STATUS_AWAITING_PRICE = 'awaiting price';
    private static final String EMAIL_TEMPLATE_UNIQUE_NAME = 'AITM_SendToLocationManager';
    
    @isTest 
    static void testSendNotificationEmails() {

        BaseUtilsTestSetup testSetup = new BaseUtilsTestSetup().generateData();

        AITM_Tender__c tender = testSetup.tender;

        List<AITM_Tender_Location__c> tenderLocations = testSetup.tenderLocations;

        List<String> ccAddresses = new List<String>();
        Id locationManagerId = tenderLocations[0].AITM_Location_Manager__c;
        EmailTemplate emailTemplate = AITM_BaseUtils.getEmailTemplate(EMAIL_TEMPLATE_UNIQUE_NAME);

        Test.startTest();
            Integer emailbefore = Limits.getEmailInvocations();
            Messaging.SingleEmailMessage emailMessage = AITM_BaseUtils.createEmailMessage( locationManagerId, emailTemplate,  tenderLocations[0].Id, tender.Owner.Name, ccAddresses);
            AITM_BaseUtils.sendEmails(emailMessage);
            List<String> listString = AITM_BaseUtils.getTextByLines(null);
            System.assertNotEquals(emailbefore, Limits.getEmailInvocations(), 'should have decreased');
        Test.stopTest();
        System.assertEquals(new List<String>(), listString);
    }

    @isTest
    static void testMultiLineBodySendNotificationEmails() {

        BaseUtilsTestSetup testSetup = new BaseUtilsTestSetup().generateData();

        AITM_Tender__c tender = testSetup.tender;

        List<AITM_Tender_Location__c> tenderLocations = testSetup.tenderLocations;

        List<String> ccAddresses = new List<String>();
        Id locationManagerId = tenderLocations[0].AITM_Location_Manager__c;
        EmailTemplate emailTemplate = AITM_BaseUtils.getEmailTemplate(EMAIL_TEMPLATE_UNIQUE_NAME);

        Test.startTest();
            Integer emailbefore = Limits.getEmailInvocations();
            Messaging.SingleEmailMessage emailMessage = AITM_BaseUtils.createEmailMessage( locationManagerId, emailTemplate,  tenderLocations[0].Id, tender.Owner.Name, ccAddresses);
            AITM_BaseUtils.sendEmails(emailMessage);
            String textBody = 'abc\nxyx';
            List<String> listString = AITM_BaseUtils.getTextByLines(textBody);
            System.assertNotEquals(emailbefore, Limits.getEmailInvocations(), 'should have decreased');
        Test.stopTest();
        System.assertEquals(new List<String>{'abc','xyx'}, listString);
    }

    @isTest
    static void testSendNotificationEmailsBulk() {

        BaseUtilsTestSetup testSetup = new BaseUtilsTestSetup().generateData();

        AITM_Tender__c tender = testSetup.tender;

        List<AITM_Tender_Location__c> tenderLocations = testSetup.tenderLocations;

        EmailTemplate emailTemplate = AITM_BaseUtils.getEmailTemplate(EMAIL_TEMPLATE_UNIQUE_NAME);

        Test.startTest();
            Integer emailbefore = Limits.getEmailInvocations();

            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            for(AITM_Tender_Location__c tenderLocation : tenderLocations) {

                List<String> ccAddresses = new List<String>();
                Id locationManagerId =  tenderLocation.AITM_Location_Manager__c;

                Messaging.SingleEmailMessage message = AITM_BaseUtils.createEmailMessage( locationManagerId, emailTemplate, tenderLocation.Id, tender.Owner.Name, ccAddresses);
                mails.add(message);
            }
            AITM_BaseUtils.sendEmails(mails);
            System.assertNotEquals(emailbefore, Limits.getEmailInvocations(), 'should have decreased');
        Test.stopTest();

    }

    @isTest
    static void testPostChatterWithMention() {

        BaseUtilsTestSetup testSetup = new BaseUtilsTestSetup().generateData();
        List<AITM_Tender_Location__c> tenderLocations = [SELECT Id, AITM_Location_Manager__c FROM AITM_Tender_Location__c WHERE AITM_Status__c = :TENDER_LOCATION_STATUS_AWAITING_PRICE ];
        List<Id> notificationReceivers = new List<Id>();
        AITM_Tender__c tender = testSetup.tender;
        for(AITM_Tender_Location__c tenderLocation : tenderLocations) {
            notificationReceivers.add(tenderLocation.AITM_Location_Manager__c);
        }

        Test.startTest();
            ConnectApi.BatchInput message = AITM_BaseUtils.createChatterMessageWithMention(tender.Id, notificationReceivers[0], 'Tender Created');
            List<ConnectApi.BatchInput>  chatterBatchInputs = AITM_BaseUtils.postToChatter(message);
        Test.stopTest();

        System.assertEquals(null, chatterBatchInputs);

    }

    @isTest
    static void testPostChatterWithMentionBulk() {

        BaseUtilsTestSetup testSetup = new BaseUtilsTestSetup().generateData();
        List<AITM_Tender_Location__c> tenderLocations = [SELECT Id, AITM_Location_Manager__c FROM AITM_Tender_Location__c WHERE AITM_Status__c = :TENDER_LOCATION_STATUS_AWAITING_PRICE ];
        List<Id> notificationReceivers = new List<Id>();
        AITM_Tender__c tender = testSetup.tender;
        for(AITM_Tender_Location__c tenderLocation : tenderLocations) {
            notificationReceivers.add(tenderLocation.AITM_Location_Manager__c);
        }

        Test.startTest();
            List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
            for (Id locationManagerId : notificationReceivers) {
                ConnectApi.BatchInput message = AITM_BaseUtils.createChatterMessageWithMention(tender.Id, locationManagerId, 'Tebder Created');
                batchInputs.add(message);
            }
            List<ConnectApi.BatchInput>  chatterBatchInputs = AITM_BaseUtils.postToChatter(batchInputs);
        Test.stopTest();

        System.assertEquals(null, chatterBatchInputs);

    }

    @isTest
    static void testGetPickValues() {
        Test.startTest();
            List<selectOption> selectOptions = AITM_BaseUtils.getPickValues('AITM_Tender_Location_Line_Item__c', 'AITM_Currency__c', null);
            List<selectOption> selectOptionsWithFirstVal = AITM_BaseUtils.getPickValues('AITM_Tender_Location_Line_Item__c', 'AITM_Currency__c', 'USD');
        Test.stopTest();
        System.assert(selectOptions.size() > 0);
        System.assertEquals(selectOptions.size()+1, selectOptionsWithFirstVal.size());
    }

    @isTest
    static void testGetFieldValueType() {
        Test.startTest();
            String valueType = AITM_BaseUtils.getFieldValueType('AITM_Tender_Location_Line_Item__c', 'AITM_Start_Date__c');
        Test.stopTest();
        System.assertEquals(VALUE_TYPE_DATE, valueType);
    }

    @isTest
    static void testCreateContentVersionWillCreateFileRowInContentVersionTable() {
        String fileName = 'text.txt';

        Test.startTest();
            AITM_BaseUtils.createContentVersion(Blob.valueOf('Some file body'), fileName);
        Test.stopTest();
        System.assertEquals(1, [SELECT Count() FROM ContentVersion WHERE PathOnClient = :fileName]);
    }
    /*
    static @isTest void testCreateContentVersionStaticResource() {
        Map<String,String> MAP_NEWOFFER_MSDS_FILE_STATIC_RESOURCE = new Map<String,String>{'AITM_NewOfferMSDS2101ContractTerms'=>Label.AITM_NewOfferPDFMSDS2101FilePrefix,'AITM_NewOfferMSDS2102ContractTerms'=>Label.AITM_NewOfferPDFMSDS2102FilePrefix,'AITM_NewOfferMSDS2105ContractTerms'=>Label.AITM_NewOfferPDFMSDS2105FilePrefix};
        List<StaticResource> staticResource = [SELECT Name,Body FROM StaticResource WHERE Name in :MAP_NEWOFFER_MSDS_FILE_STATIC_RESOURCE.keySet() LIMIT 5];
        Test.startTest();
            AITM_BaseUtils.createContentVersion(staticResource, MAP_NEWOFFER_MSDS_FILE_STATIC_RESOURCE);
        Test.stopTest();
        System.assertEquals(3, [SELECT Count() FROM ContentVersion]);
    }
    */
    @isTest 
    static void testUpdateContentVersionWillUpdateFileRowInContentVersionTable() {
        String fileName = 'text.txt';

        Test.startTest();
            ContentVersion content = AITM_BaseUtils.createContentVersion(Blob.valueOf('Some file body'), fileName);
            AITM_BaseUtils.updateContentVersion(Blob.valueOf('Some file body1'), fileName, content.Id);  
        Test.stopTest();
        System.assertEquals(1, [SELECT Count() FROM ContentVersion WHERE PathOnClient = :fileName]);
    }

    @isTest
    static void testCreateChatterPostToRelateWillCreateChatterPostRecordIfValidContentVersionSent() {
        BaseUtilsTestSetup testSetup = new BaseUtilsTestSetup().generateData(true);
        String fileName = 'text.txt';
        ContentVersion testDocument = AITM_BaseUtils.createContentVersion(Blob.valueOf('Some file body'), fileName);

        Test.startTest();
            FeedItem result = AITM_BaseUtils.createChatterPostToRelate(fileName, testSetup.tender.Id, testDocument.Id);
        Test.stopTest();
        System.assertEquals(1, [SELECT Count() FROM FeedItem WHERE ParentId = :testSetup.tender.Id]);
    }

    @isTest
    static void testCreateChatterPostToRelateWillCreateChatterPostRecordIfValidListContentVersionSent() {
        BaseUtilsTestSetup testSetup = new BaseUtilsTestSetup().generateData(true);
        String fileName = 'text.txt';
        List<ContentVersion> contentList = new List<ContentVersion>();
        ContentVersion testDocument = AITM_BaseUtils.createContentVersion(Blob.valueOf('Some file body'), fileName);
        contentList.add(testDocument);
        Test.startTest();
            List<FeedItem> result = AITM_BaseUtils.createChatterPostToRelate(fileName, testSetup.tender.Id, contentList);
        Test.stopTest();
        System.assertEquals(1, [SELECT Count() FROM FeedItem WHERE ParentId = :testSetup.tender.Id]);
    }

    @isTest
    static void testLABPURL() {
        String labpURL;
        try {
            labpURL = AITM_BaseUtils.getLABPURL();
            System.assertNotEquals(labpURL, '', 'LABP Community URL Link');
        } catch(Exception ex) {
            System.assertEquals(labpURL, '', 'Data not found');
        }
    }

    @isTest 
    static void testLABPCommunity() {
        String labpURL;
        try {
            labpURL = AITM_BaseUtils.getLABPCommunityId();
            System.assertNotEquals(labpURL, '', 'LABP Community URL Link');
        } catch(Exception ex) {
            System.assertEquals(labpURL, '', 'Data not found');
        }
    }

    @isTest
    static void testProductDescription() {
        String productName;
        try {
            productName = AITM_BaseUtils.getProductDescription('Jet A @ 1 CM=0.8 MT');
            System.assertEquals(productName, 'Jet A', 'Product name is ' + productName);
        } catch(Exception ex) {
            System.assertEquals(productName, '', 'Data not found');
        }
    }

    @isTest     
    static void testProductDescriptionException() {
        String productName;
        productName = AITM_BaseUtils.getProductDescription('ABC');
        System.assertEquals(productName, '', 'Data not found');
    }

    @isTest 
    static void testTenderingURL() {
        String tenderingURL;
        tenderingURL = AITM_BaseUtils.getTenderingURL();
        System.assertNotEquals(tenderingURL, '', 'Tendering URL Link');
    }
    
    private class BaseUtilsTestSetup extends AITM_TestSetup {
        public AITM_BaseUtils classUnderTest;

        public List<Account> accounts;
        public List<AITM_Location__c> locations;
        public AITM_Tender__c tender;
        public List<AITM_Tender_Location_Line_Item__c> tenderLocationLineItems;
        public List<AITM_Tender_Location__c> tenderLocations;
        public List<User> locationManagers;

        public BaseUtilsTestSetup generateData() {
            classUnderTest = new AITM_BaseUtils();

            accounts = createAccounts(10);
            insert accounts;

            locations = createLocations(10);
            insert locations;
            setLocationsDelegates(locations);

            tender = createTender();
            tender.AITM_Bids_In_By__c = Date.today().addMonths(1);
            tender.AITM_Density__c = '331';

            insert tender;

            createTenderAccounts();

            locationManagers = createUsers(10, 'Air_TMLocation Manager');
            insert locationManagers;

            tenderLocations = createTenderLocations();
            insert tenderLocations;

            attachLocationManagersToTenderLocations(locationManagers, tenderLocations);
            setTenderLocationsStatus(tenderLocations);

            return this;
        }

        public BaseUtilsTestSetup generateData(Boolean simpleVersionFlag) {
            classUnderTest = new AITM_BaseUtils();
            
            tender = createTender();
            insert tender;

            return this;
        }

        public List<AITM_Tender_Location__c> createTenderLocations() {
            List<AITM_Tender_Location__c> tenderLocations = new List<AITM_Tender_Location__c>();
            for(AITM_Location__c location : locations){
                tenderLocations.add(
                    createTenderLocation(tender.Id, location.Id)
                );
            }
            return tenderLocations;
        }

        public void attachLocationManagersToTenderLocations(List<User> locationManagers, List<AITM_Tender_Location__c> tenderLocations) {

            List<AITM_Tender_Location__c> result = new List<AITM_Tender_Location__c>();
            Integer index = 0;

            for(AITM_Tender_Location__c tenderLocation : tenderLocations){
                tenderLocation.AITM_Location_Manager__c = locationManagers[index].Id;
                result.add(tenderLocation);
                index++;
            }
            upsert result;

        }

        public void createTenderAccounts() {
            insert createTenderAccounts(new List<AITM_Tender__c>{tender}, accounts);
        }

        public void createTenderLocationLineItems() {
            tenderLocationLineItems = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, new List<AITM_Location__c>{locations[0]});
        }

        public void setLocationsDelegates(List<AITM_Location__c> locations){
            Integer i = 0;
            for(AITM_Location__c location : locations) {
                if(i < 2) {
                    location.AITM_Delegates__c = 'test1@testmails555.com\ntest2@testmails555.com';
                }
                i++;
            }
            update locations;
        }

        public void setTenderLocationsStatus(List<AITM_Tender_Location__c> tenderLocations){
            Integer i = 0;
            for(AITM_Tender_Location__c tenderLocation : tenderLocations) {
                if(i < 2) {
                    tenderLocation.AITM_Status__c = TENDER_LOCATION_STATUS_AWAITING_PRICE;
                }
                i++;
            }
            upsert tenderLocations;
        }
    }
}
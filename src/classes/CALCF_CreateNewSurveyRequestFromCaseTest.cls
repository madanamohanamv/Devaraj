/***************************************************************************************************
* Description : Unit Tests for Create_New_Survey_Request_From_Case Process Builder and
*				Create New Survey Request flow
*
* Date          Version #           Author              Description
* --------------------------------------------------------------------------------------------------
*
* 2019-JAN-30   1.0                 Maros Zilka     	Initial version
*
***************************************************************************************************/

@isTest
private class CALCF_CreateNewSurveyRequestFromCaseTest {

    @isTest
    static void createNewSurveyRequestFromCaseTest() {
        Account testAccount = new Account();
        Contact testContact = new Contact();
        Case testCase = new Case();
        
        testAccount.Name = 'Test Account';
        testAccount.Business_Unit__c = 'Lubricants - Automotive';
        testAccount.Sales_Organisation__c = 'UK01';

        insert testAccount;
        
        testContact.FirstName = 'First';
        testContact.LastName = 'Last';
        testContact.Email = 'example@example.com';
        testContact.Home_Location__c = 'United Kingdom';
        testContact.Preferred_Language__c = 'English-British';
        testContact.TimeZone__c = '(GMT) Greenwich Mean Time : Dublin, Edinburgh, Lisbon, London';
        testContact.Test_Contact__c = lcf_Settings__c.getInstance().Test_Mode__c;
        testContact.AccountId = testAccount.Id;

        insert testContact;
        
        testCase.AccountId = testAccount.Id;
        testCase.ContactId = testContact.Id;
        testCase.Complaint__c = true;
        testCase.Siebel_Last_Updated_Date__c = Date.today();  
        
        insert testCase;
        
        testCase.Status = 'Closed';

        update testCase;

		testCase = [SELECT Id, CALCF_Not_Surveyed_Reason__c, CALCF_LCF_Not_Surveyed__c FROM Case LIMIT 1];
        
        // Expecting survey error 12 - no active template for this country
        system.debug(testCase.CALCF_Not_Surveyed_Reason__c);
        
        system.assert(testCase.CALCF_Not_Surveyed_Reason__c == 'Survey Error 12');
        system.assert(testCase.CALCF_LCF_Not_Surveyed__c);
    }
}
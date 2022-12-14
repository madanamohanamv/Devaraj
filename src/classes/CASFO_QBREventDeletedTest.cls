/**
 * @Who     Maros Zilka
 * @when    20-09-2018
 * @what    Test class for the CASFO_QBREventDeleted.
 **/

@isTest()
public class CASFO_QBREventDeletedTest {
     @isTest
    public static void updateAccountWhenQBRDeletedTest() {
        List<Account> accounts = getAccounts();
        List<Event> events = getEvents(accounts);
        
        Test.startTest();
        delete events;
        Test.stopTest();
        
        accounts = [SELECT Id, CASFO_QBR_Planned__c FROM Account WHERE Name LIKE 'QBR Test%'];
        
        for (Account a : accounts) {
            System.assert(!a.CASFO_QBR_Planned__c, 'Account should not be planned.');
        }
    }
    
    private static List<Account> getAccounts () {
        List<Account> accounts = new List<Account>();
        Integer i;
        
        Id recordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Customer').getRecordTypeId();
        
        for (i = 0; i < 200; i++) {
            Account a = new Account();
            
            a.Name = 'QBR Test ' + i;
            a.RecordTypeId = recordTypeID;
            a.Account_ERP_ID__c = String.valueOf(i);
            
            accounts.add(a);
        }
        
        insert accounts;
        return accounts;
    }
    
    private static List<Event> getEvents (List<Account> accounts) {
        List<Event> events = new List<Event>();
        
        for (Account a : accounts) {
            Event e = new Event();
            
            e.Type = 'Quarterly Business Review';
            e.WhatId = a.Id;
            e.Subject = 'QBR meeting for ' + a.Name;
            e.DurationInMinutes = 60;
            e.ActivityDateTime = DateTime.now();

            events.add(e);
        }
        
        insert events;
        return events;
    }
}
/** 
* This test class contains unit tests for validating the behavior of 
* CAJBP_JbpActivityTriggerHandler.cls class for the CAJBP_JbpActivityTrigger trigger.
* 
* @autor Jana Cechova
* Created: 10 September, 2018
*/

@isTest(seeAllData = false) 
private class CAJBP_JbpActivityTriggerHandler_Test{
    
    static integer bulkSize=200;
    static list<CAJBP_Joint_Business_Plan__c> lstJBPs = new list<CAJBP_Joint_Business_Plan__c>();
    static list<CAJBP_Objective__c> lstObjectives = new list<CAJBP_Objective__c>();
    static list<CAJBP_JBP_Activity__c> lstJBPActivities = new list<CAJBP_JBP_Activity__c>();
    static list<CAJBP_Distributor_Joint_Activity_Fund__c> lstDJAFs = new list<CAJBP_Distributor_Joint_Activity_Fund__c>();


    /**
    * The purpose of this method is to create test data used in unit tests.
    * @see               
    * @param    
    * @return     void
    */
    static void createTestData() {
         Account account = new Account(
            Name = 'Power Plant',
            Type = 'ZMHI'
         );
        insert account;
        
        
        for(Integer i=0; i<bulkSize; i++){   
           lstJBPs.add(new CAJBP_Joint_Business_Plan__c(
                CAJBP_Year__c = string.valueOf(date.today().year()),
                CAJBP_Account__c = account.id,
                CAJBP_State__c = 'Closed'
                
            ));
        }
        
        insert lstJBPs;
        
        for(Integer j=0; j<bulkSize; j++){
         lstObjectives.add(new CAJBP_Objective__c(
           //  Name = 'TestName' + j,
             CAJBP_Joint_Business_Plan__c = lstJBPs[j].id
         )
         );
        }
        insert lstObjectives;
        
        
        for(Integer k=0; k<bulkSize; k++){
        
            lstJBPActivities.add(new CAJBP_JBP_Activity__c(
                Name = 'TestName' + k,
                CAJBP_Objective__c = lstObjectives[k].id,
                CAJBP_Paid_for_by__c='JAF'
            )
            );
        
        }
        
        for(Integer l=0; l<bulkSize; l++){
        
            lstDJAFs.add(new CAJBP_Distributor_Joint_Activity_Fund__c(
               CAJBP_Joint_Business_Plan__c = lstJBPs[l].id
                )
            );
        
        }
        
    }
    
    static testMethod void positiveTestOneRecordWithPaidForByEqualsJAF() {
        bulkSize = 1;
        createTestData();
        
        list<CAJBP_JBP_Activity__c> lstJBPactivitiesToAsserts = new list<CAJBP_JBP_Activity__c>([SELECT Id , CAJBP_Distributor_Joint_Activity_Fund__c 
                                                                                                       FROM CAJBP_JBP_Activity__c]);
            system.assertEquals(0,lstJBPactivitiesToAsserts.size());
    
            system.Test.startTest();
                 try {
                    insert lstJBPActivities;
                }  catch(DmlException e){
                    system.assert( e.getMessage().contains('Distributor Joint Activity Fund does not exist.'),e.getMessage());
                
                }
                
            system.Test.stopTest();
            
            lstJBPactivitiesToAsserts = new list<CAJBP_JBP_Activity__c>([SELECT Id , CAJBP_Distributor_Joint_Activity_Fund__c 
                                                                          FROM CAJBP_JBP_Activity__c]);
            system.assertEquals(0,lstJBPactivitiesToAsserts.size(),'JBP Activity was created unexpected.');
    }   
    
    static testMethod void positiveTestOneRecordWithPaidForByNotEqualsJAF() {
        bulkSize = 1;
        createTestData();
        
        for(CAJBP_JBP_Activity__c  objActivity: lstJBPActivities){
        
            objActivity.CAJBP_Paid_for_by__c='Partner';
            
        }
        
        list<CAJBP_JBP_Activity__c> lstJBPactivitiesToAsserts = new list<CAJBP_JBP_Activity__c>([SELECT Id , CAJBP_Distributor_Joint_Activity_Fund__c 
                                                                                                       FROM CAJBP_JBP_Activity__c]);
            system.assertEquals(0,lstJBPactivitiesToAsserts.size());
    
            system.Test.startTest();
                
                    insert lstJBPActivities;
                
            system.Test.stopTest();
            
            lstJBPactivitiesToAsserts = new list<CAJBP_JBP_Activity__c>([SELECT Id , CAJBP_Distributor_Joint_Activity_Fund__c 
                                                                          FROM CAJBP_JBP_Activity__c]);
            system.assertEquals(1,lstJBPactivitiesToAsserts.size(),'JBP Activity was not created correctly.');
            system.assertEquals(null,lstJBPactivitiesToAsserts[0].CAJBP_Distributor_Joint_Activity_Fund__c ,'JBP Activity was not created correctly.');
    }   
    
     static testMethod void positiveTestWithPaidForByEqualsJAFandJAFisExists() {
         bulkSize = 1;
         createTestData();
         
         list<CAJBP_JBP_Activity__c> lstJBPactivitiesToAsserts = new list<CAJBP_JBP_Activity__c>([SELECT Id , CAJBP_Distributor_Joint_Activity_Fund__c 
                                                                                                       FROM CAJBP_JBP_Activity__c]);
         system.assertEquals(0,lstJBPactivitiesToAsserts.size());
         
         insert lstDJAFs;
         
         system.Test.startTest();
                
             insert lstJBPActivities;
                
         system.Test.stopTest();
            
            
            
         lstJBPactivitiesToAsserts = new list<CAJBP_JBP_Activity__c>([SELECT Id , CAJBP_Distributor_Joint_Activity_Fund__c 
                                                                          FROM CAJBP_JBP_Activity__c]);
         system.assertEquals(1,lstJBPactivitiesToAsserts.size(),'JBP Activity was not created correctly.');
            
            
         list<CAJBP_Distributor_Joint_Activity_Fund__c> lstDJAFtoAsserts= new list<CAJBP_Distributor_Joint_Activity_Fund__c>([SELECT Id 
                                                                                                              FROM CAJBP_Distributor_Joint_Activity_Fund__c]
         
         
                                                                                                             );
         
         system.assertEquals(lstDJAFtoAsserts[0].id,lstJBPactivitiesToAsserts[0].CAJBP_Distributor_Joint_Activity_Fund__c ,'DJAF on JBP Activity was not populated correctly.');
     
     }
     
     static testMethod void positiveTestWithPaidForByEqualsJAFBulk() {
        bulkSize = 201;
        createTestData();
        
        list<CAJBP_JBP_Activity__c> lstJBPactivitiesToAsserts = new list<CAJBP_JBP_Activity__c>([SELECT Id , CAJBP_Distributor_Joint_Activity_Fund__c 
                                                                                                       FROM CAJBP_JBP_Activity__c]);
            system.assertEquals(0,lstJBPactivitiesToAsserts.size());
    
            system.Test.startTest();
                 try {
                    insert lstJBPActivities;
                }  catch(DmlException e){
                    system.assert( e.getMessage().contains('Distributor Joint Activity Fund does not exist.'),e.getMessage());
                
                }
                
            system.Test.stopTest();
            
            lstJBPactivitiesToAsserts = new list<CAJBP_JBP_Activity__c>([SELECT Id , CAJBP_Distributor_Joint_Activity_Fund__c 
                                                                          FROM CAJBP_JBP_Activity__c]);
            system.assertEquals(0,lstJBPactivitiesToAsserts.size(),'JBP Activity was created unexpected.');
         
         
     }
     
     static testMethod void positiveTestWithPaidForByNotEqualsJAFBulk() {
        bulkSize = 201;
        createTestData();
        
         for(CAJBP_JBP_Activity__c  objActivity: lstJBPActivities){
        
            objActivity.CAJBP_Paid_for_by__c='Partner';
            
        }
        
        list<CAJBP_JBP_Activity__c> lstJBPactivitiesToAsserts = new list<CAJBP_JBP_Activity__c>([SELECT Id , CAJBP_Distributor_Joint_Activity_Fund__c 
                                                                                                       FROM CAJBP_JBP_Activity__c]);
        system.assertEquals(0,lstJBPactivitiesToAsserts.size());
    
        system.Test.startTest();
                
            insert lstJBPActivities;
                
        system.Test.stopTest();
            
        lstJBPactivitiesToAsserts = new list<CAJBP_JBP_Activity__c>([SELECT Id , CAJBP_Distributor_Joint_Activity_Fund__c 
                                                                          FROM CAJBP_JBP_Activity__c]);
        
        system.assertEquals(201,lstJBPactivitiesToAsserts.size(),'JBP Activity was not created correctly.');
        
        for(CAJBP_JBP_Activity__c objActivity : lstJBPactivitiesToAsserts ){
        
            system.assertEquals(null,objActivity.CAJBP_Distributor_Joint_Activity_Fund__c ,'JBP Activity was not created correctly.');
        
        }
      
    
         
     }
     
     static testMethod void positiveTestWithPaidForByEqualsJAFandJAFExistsBulk() {
        bulkSize = 201;
        createTestData();
        
        list<CAJBP_JBP_Activity__c> lstJBPactivitiesToAsserts = new list<CAJBP_JBP_Activity__c>([SELECT Id , CAJBP_Distributor_Joint_Activity_Fund__c 
                                                                                                       FROM CAJBP_JBP_Activity__c]);
        system.assertEquals(0,lstJBPactivitiesToAsserts.size());
         
        insert lstDJAFs;
         
        system.Test.startTest();
                
         insert lstJBPActivities;
                
        system.Test.stopTest();
            
            
            
        lstJBPactivitiesToAsserts = new list<CAJBP_JBP_Activity__c>([SELECT Id , CAJBP_Distributor_Joint_Activity_Fund__c 
                                                                          FROM CAJBP_JBP_Activity__c]);
        system.assertEquals(201,lstJBPactivitiesToAsserts.size(),'JBP Activity was not created correctly.');
            
            
         list<CAJBP_Distributor_Joint_Activity_Fund__c> lstDJAFtoAsserts= new list<CAJBP_Distributor_Joint_Activity_Fund__c>([SELECT Id 
                                                                                                              FROM CAJBP_Distributor_Joint_Activity_Fund__c]
         
                                                                                                             );
         for(CAJBP_JBP_Activity__c objActivity: lstJBPactivitiesToAsserts ){
         
              System.assertNotEquals(lstDJAFtoAsserts[0].id,objActivity.CAJBP_Distributor_Joint_Activity_Fund__c ,'DJAF on JBP Activity was not populated correctly.');
         
         }
        
         
     }
            
}
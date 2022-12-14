/**
 * @author 			Jan Majling
 * @date 			26/07/2018
 * @group			CAJBP
 * @description     test class for CAJBP_JbpTriggerHandler
 * 
 * history
 * 26/07/2018	Jan Majling				Created
 * 01/08/2018	Jana Cechova			Added check in progress tests
 */
 
@isTest(seeAllData = false)

private class CAJBP_JbpTriggerHandlerTest {

    @testSetup static void setup() {
        Account account = new Account(
            Name = 'Power Plant',
            Type = 'ZMHI'
        );
        insert account;
    }
    
    @isTest static void testNameChangeOnInsert() {
        Account account = [SELECT Id FROM Account WHERE Name = 'Power Plant' LIMIT 1];
        CAJBP_Joint_Business_Plan__c jbp = new CAJBP_Joint_Business_Plan__c(
            CAJBP_Year__c = string.valueOf(date.today().year()),
            CAJBP_Account__c = account.Id  
        );

        Test.startTest();
        insert jbp;
        Test.stopTest();

        jbp = [SELECT Name, CAJBP_Joint_Business_Plan_Name__c  FROM CAJBP_Joint_Business_Plan__c WHERE Id = :jbp.Id];

        System.assertEquals('Power Plant Customer Group JBP '+string.valueOf(date.today().year()), jbp.CAJBP_Joint_Business_Plan_Name__c );
    }

    @isTest static void testNameChangeOnUpdate() {
        Account account = [SELECT Id FROM Account WHERE Name = 'Power Plant' LIMIT 1];
        
        CAJBP_Joint_Business_Plan__c jbp = new CAJBP_Joint_Business_Plan__c(
            CAJBP_Year__c = string.valueOf(date.today().year()),
            CAJBP_Account__c = account.Id,
            CAJBP_State__c = 'Withdrawn'
        );
        insert jbp;
         
        jbp = [SELECT Name, CAJBP_Joint_Business_Plan_Name__c FROM CAJBP_Joint_Business_Plan__c WHERE CAJBP_Account__c = :account.Id];
        jbp.CAJBP_Year__c = string.valueOf(date.today().year()+1);
       
        Test.startTest();
        update jbp;
        Test.stopTest();

        jbp= [SELECT Name, CAJBP_Joint_Business_Plan_Name__c FROM CAJBP_Joint_Business_Plan__c WHERE Id = :jbp.Id];
        system.debug(logginglevel.error, 'jbp' + jbp);
        
        
        System.assertEquals('Power Plant Customer Group JBP ' + string.valueOf(date.today().year()+1), jbp.CAJBP_Joint_Business_Plan_Name__c );
    }

    @isTest static void testNameChangeOnBulkInsert() {
        Account account = [SELECT Id FROM Account WHERE Name = 'Power Plant' LIMIT 1];

        List<CAJBP_Joint_Business_Plan__c> jbps = new List<CAJBP_Joint_Business_Plan__c>();
        for(Integer i=0; i<200; i++){
            CAJBP_Joint_Business_Plan__c jbp = new CAJBP_Joint_Business_Plan__c(
                CAJBP_Year__c = string.valueOf(date.today().year()),
                CAJBP_Account__c = account.Id,
                CAJBP_State__c = 'Closed'
            );
            jbps.add(jbp);
        }

        Test.startTest();
        insert jbps;
        Test.stopTest();


        for(CAJBP_Joint_Business_Plan__c jbp : [SELECT Name, CAJBP_Joint_Business_Plan_Name__c FROM CAJBP_Joint_Business_Plan__c WHERE CAJBP_Account__c = :account.Id]){
            System.assertEquals('Power Plant Customer Group JBP ' + string.valueOf(date.today().year()), jbp.CAJBP_Joint_Business_Plan_Name__c );
        }
    }
  
    static testmethod void checkINproggressStatus2records() {
       Account account = [SELECT Id FROM Account WHERE Name = 'Power Plant' LIMIT 1];
        
       CAJBP_Joint_Business_Plan__c jbp1 = new CAJBP_Joint_Business_Plan__c(
            CAJBP_Year__c = string.valueOf(date.today().year()),
            CAJBP_Account__c = account.Id,
            CAJBP_State__c = 'In Progress'
        );
       insert jbp1;
       
       list<CAJBP_Joint_Business_Plan__c > lstJBPsToCheck1 = new list<CAJBP_Joint_Business_Plan__c >();
       lstJBPsToCheck1 = [Select id from CAJBP_Joint_Business_Plan__c where Id =:jbp1.id];
       system.assertEquals(1,lstJBPsToCheck1.size());
       
       CAJBP_Joint_Business_Plan__c jbp2 = new CAJBP_Joint_Business_Plan__c(
            CAJBP_Year__c = string.valueOf(date.today().year()),
            CAJBP_Account__c = account.Id,
            CAJBP_State__c = 'In Progress'
        );
 
       system.Test.StartTest();
       
       try{ 
          
          insert jbp2;
        
        }catch(DmlException e){
          
          system.assert( e.getMessage().contains('Joint Business Plan with State In Progress or Draft already exists.'),e.getMessage());
        }// catch
             
       system.Test.StopTest();

       list<CAJBP_Joint_Business_Plan__c >lstJBPtoCheck = new list<CAJBP_Joint_Business_Plan__c >([Select id, CAJBP_Account__c, CAJBP_State__c, CAJBP_Year__c  from CAJBP_Joint_Business_Plan__c where CAJBP_Account__c =: account.Id]);
       system.debug(logginglevel.error, 'lstJBPtoCheck ' +lstJBPtoCheck );
       system.assertEquals(1,lstJBPtoCheck.size());
    
    
    }
    
    static testmethod void checkINproggressStatusBulkRecords() {
       
       Account account = [SELECT Id FROM Account WHERE Name = 'Power Plant' LIMIT 1];
      
       list<CAJBP_Joint_Business_Plan__c> lstToInsert = new list <CAJBP_Joint_Business_Plan__c>();
        
       CAJBP_Joint_Business_Plan__c jbp1 = new CAJBP_Joint_Business_Plan__c(
            CAJBP_Year__c = string.valueOf(date.today().year()),
            CAJBP_Account__c = account.Id,
            CAJBP_State__c = 'In Progress'
        );
       insert jbp1;
       
       for(Integer i=0; i<100; i++){
            CAJBP_Joint_Business_Plan__c jbp = new CAJBP_Joint_Business_Plan__c(
                CAJBP_Year__c = string.valueOf(date.today().year()),
                CAJBP_Account__c = account.Id,
                CAJBP_State__c = 'In Progress'
            );
            lstToInsert.add(jbp);
        }
        
        for(Integer j=100; j<200; j++){
            CAJBP_Joint_Business_Plan__c jbp = new CAJBP_Joint_Business_Plan__c(
                CAJBP_Year__c = string.valueOf(date.today().year()),
                CAJBP_Account__c = account.Id,
                CAJBP_State__c = 'Draft'
            );
            lstToInsert.add(jbp);
        }
       
       system.Test.StartTest();
       
       try{ 
                insert lstToInsert;
           }
            catch(DmlException e){
                system.assert( e.getMessage().contains('Joint Business Plan with State In Progress or Draft already exists.'),e.getMessage());
                
                
            }// catch
        
             
       system.Test.StopTest();

       list<CAJBP_Joint_Business_Plan__c>lstJBPtoCheck = new list<CAJBP_Joint_Business_Plan__c >([Select id from CAJBP_Joint_Business_Plan__c ]);
       system.assertEquals(1,lstJBPtoCheck.size(),'JBP was created unexpected.');
    
    
    }
    

    
    
}
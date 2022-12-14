/**************************************************************************
 * @author           George
 * @date             01/December/2017
 * @group            AirBP
 * @description      Test class for AITM_InvitationEmailGenerator
 
 * history
 * 01/December/2017  George       Created
 * 09/Aug/2018       Ravi         Modified - added method level comments as per coding standards
 *******************************************************************/
 @isTest 
 private class AITM_InvitationEmailGeneratorTests {
    
    /**
     * @description tests to check if valid Tender is passed to Generator valid email ID
     * @param  null
     * @return null
     */  
    @isTest  
    private static void checkIfValidTenderIdIsPassedToGeneratorValidEmailDTOIsGenerated() {
      
      Test.startTest();
          InvitationEmailGeneratorTestSetup setup = new InvitationEmailGeneratorTestSetup().generateData();
          AITM_InvitationEmailGenerator.Generator generator = new AITM_InvitationEmailGenerator.Generator(setup.tender.Id, AITM_TenderDao.NONPOLISH);
      Test.stopTest();
            
      AITM_EmailGeneratorController.EmailDTO generatedEmailDTO = generator.generate();

      System.assertEquals(1, generatedEmailDTO.emailAddresses.size(),'Email address size should be 1');
      //System.assertEquals(true, generatedEmailDTO.emailAddresses[0].isTo,'Generated email ID should be true');
      //System.assertEquals(UserInfo.getUserEmail(), generatedEmailDTO.emailAddresses[0].targetEmail,'Generated email ID should be current user');
      System.assert(String.isNotBlank(generatedEmailDTO.subject),'Email subject should not be blank');
      System.assert(generatedEmailDTO.emailBodies.size() > 1, 'Should be complex structure');
    }
    
    /**
     * @description test data holder InvitationEmailGenerator controller inner class
     */
    private class InvitationEmailGeneratorTestSetup extends AITM_TestSetup {
      public final Integer ITEMS_SIZE = 10;
      public List<Account> accounts;
      public List<AITM_Tender_Account__c> tenderAccounts;
      public List<AITM_Location__c> locations;
      public AITM_Tender__c tender;
      public List<AITM_Tender_Location_Line_Item__c> tenderLocations;
        
     /**
      * @description generate test data i.e. accounts, location, tenders
      * @param  null
      * @return InvitationEmailGeneratorTestSetup
      */
      public InvitationEmailGeneratorTestSetup generateData() {
        accounts = createAccounts(ITEMS_SIZE);
        insert accounts;

        locations = createLocations(ITEMS_SIZE);
        for(AITM_Location__c location : locations){
          location.AITM_Country__c = 'Spain';
        }
        insert locations;

        tender = createTender();
        tender.AITM_Bids_In_By__c = Date.today().addMonths(1);
        tender.AITM_Density__c = '331'; 
        tender.AITM_Stage__c = 'Awaiting Price';
        tender.AITM_Unit_Of_Measure__c = 'USG';
        insert tender;
        
        tenderAccounts = createTenderAccounts(new List<AITM_Tender__c>{tender}, accounts);
        insert tenderAccounts;

        AITM_Pricing_Basis__c pricingBasis = new AITM_Pricing_Basis__c(Name = 'Test');
        insert pricingBasis;

        tenderLocations = createTenderLocationLineItems(new List<AITM_Tender__c>{tender}, accounts, locations);
        for (AITM_Tender_Location_Line_Item__c lineItems : tenderLocations) {
              lineItems.AITM_Pricing_Basis__c = pricingBasis.Id;
              lineItems.AITM_Delivery_Point__c = '1';
              lineItems.AITM_Currency__c = 'USD';
              lineItems.AITM_Unit_Of_Measure__c = 'LT'; 
              lineItems.AITM_Offered_Differential__c = 1.0;
              lineItems.AITM_Offered_Volume__c = 1.0;
              lineItems.AITM_Volume__c = 1.0;
        }
        insert tenderLocations;
          
        return this;
      }
      
      /**
       * @description createContact test data 
       * @param accountId
       * @param locationId
       * @param lastName
       * @param emailValue 
       * @return Contact
       */    
      private Contact createContact(Id accountId, Id locationId, String lastName, String emailValue) {
          return new Contact(
              AccountId = accountId,
              AITM_Location__c = locationId,
              LastName = lastName,
              Email = emailValue
          );
       }
   }
}
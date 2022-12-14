@isTest
private class CAIDP_UserTriggerHandlerTest {

    @isTest 
    static void handleAfterUpdateTest() {

        User u = REIDP_TestFactory.createCommunityUser(CAIDP_UserTriggerHandlerTest.class);
        
        u.IsActive = false;

        Test.startTest();
        update u;
        Test.stopTest();

        
        u = [
            SELECT IsActive
            FROM User
            WHERE Email = :u.Email
            LIMIT 1
        ];
        
        System.assertEquals(false, u.IsActive);
    }
    
}
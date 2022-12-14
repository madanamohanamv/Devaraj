@IsTest(SeeAllData=false)
private class BPG_AuraHandledExceptionTest {
    public class MockException extends Exception {}

    @IsTest(SeeAllData=false)
    private static void itShouldThrowExceptionWithCause() {
        Test.startTest();
            MockException mock = new MockException('My Mock Exception');
            mock.initCause(new System.QueryException('Query Exception'));

            try {
                new BPG_AuraHandledException().setMessage(mock).throwException();
                System.assert(false);
            } catch (System.AuraHandledException ex) {
                System.assertEquals('My Mock Exception - Query Exception', ex.getMessage());
            }

            try {
                new BPG_AuraHandledException('###Custom Message###').throwException();
                System.assert(false);
            } catch (System.AuraHandledException ex) {
                System.assertEquals('###Custom Message###', ex.getMessage());
            }

    }
}
/*
* Custom AuraHandledException class that stores custom error message and parent exception cause.
*/
public with sharing class BPG_AuraHandledException extends Exception {

    public BPG_AuraHandledException setMessage(Exception ex) {
        if (ex != null) {
            initCause(ex);
            setMessage(ex.getMessage() + (ex.getCause() != null ? +' - ' + ex.getCause().getMessage() : ''));
        }

        return this;
    }

    //This calls the aura handle exception that should be catched in the controller or parent class.
    public void throwException() {
        AuraHandledException auraException = new AuraHandledException(getMessage());
        Exception cause = getCause();

        if (cause != null) {
            auraException.initCause(cause);
        }

        auraException.setMessage(getMessage());
        throw auraException;
    }
}
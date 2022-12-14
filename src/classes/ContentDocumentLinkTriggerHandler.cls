/**
 * @Who     Platform Team - Customer Org <adam.walker1@bp.com>
 * @when    10-04-2018
 * @what    The Generic Trigger Handler for the ContentDocumentLinkTrigger. Please add your product specific handler this class
 *          If you require any changes to this trigger, please contact a member of the Customer Org Platform Team.
 **/
public class ContentDocumentLinkTriggerHandler {

    private final List<ContentDocumentLink> newRecords;
    private final List<ContentDocumentLink> oldRecords;
    private final Map<Id, ContentDocumentLink> newMap;
    private final Map<Id, ContentDocumentLink> oldMap;

    public ContentDocumentLinkTriggerHandler(List<ContentDocumentLink> newRecords, List<ContentDocumentLink> oldRecords, Map<Id, ContentDocumentLink> newMap, Map<Id,ContentDocumentLink> oldMap) {
        this.newRecords = newRecords;
        this.oldRecords = oldRecords;
        this.newMap     = newMap;
        this.oldMap     = oldMap;
    }

    public void handleBeforeInsert() {

        //Set visibility to 'AllUsers'
        CAPL_ContentVisibilityTriggerHandler.changeVisibility(newRecords);
    }

    public void handleAfterInsert() {
        CASFO_FillNoteTitle fillNoteTitle = new CASFO_FillNoteTitle(newMap);
        fillNoteTitle.fillNoteTitle();
    }

    public void handleBeforeUpdate() {

    }

    public void handleAfterUpdate() {

    }

}
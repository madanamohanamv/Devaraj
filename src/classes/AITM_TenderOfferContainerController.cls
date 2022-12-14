public class AITM_TenderOfferContainerController {
    public static @AuraEnabled List<AITM_RelatedRecordsHolderController.FilterOption> getFilterOptions(Id tenderId) {
        return AITM_RelatedTenderLocationsHolderCntrl.getFilterOptions(tenderId);
    }

    public static @AuraEnabled void attachOfferDocuments(String tenderId, String selectedFilter) {
        AITM_TenderOfferGenerateBatch.BatchState batchState = new AITM_TenderOfferGenerateBatch.BatchState(Id.valueOf(tenderId), selectedFilter);
        new AITM_TenderOfferGenerateBatch.BatchFactory().executeBatch(batchState);
    }

    public static @AuraEnabled String check() {
        AITM_TenderOfferGenerateBatch.BatchFactory factory = new AITM_TenderOfferGenerateBatch.BatchFactory();
        return factory.check();
    }
}
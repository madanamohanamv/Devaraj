/*************************************************************************
* @author         George
* @date           01/December/2017
* @group          AirBP
* @description    controller class when Generate Offer button was clicked. It attaches Tender Offer GT&C 
*                 and MSDS PDF files(email attachments).

* history
* 01/December/2017  George       Created
* 23/April/2018     srnandan     added with sharing to outer class as per coding standard and also code comments
* 12/August/2018    srnandan     Modified AR-3316 - modified method generate and notifyAirports 
*                                adding extra param locationType
* 20/Februrary/2019  Shweta      Modified AR-5010  Modified method notifyAirports to return the non null values
*************************************************************************/
public with sharing class AITM_DeBriefEmailGeneratorController {
    
    /**
     * @description generates email DTO
     * @param  tenderId of type Id
     * @param  locationType of type String
     * @return AITM_EmailGeneratorController.EmailDTO
     */
    public static @AuraEnabled AITM_EmailGeneratorController.EmailDTO generate(Id tenderId, String locationType) {
        AITM_DeBriefEmailGenerator.Generator emailCreator = new AITM_DeBriefEmailGenerator.Generator(tenderId, locationType);
        return emailCreator.generate();
    }

    /**
     * @description notify airports with emails
     * @param  tenderId of type Id
     * @param  locationType of type String
     * @return void
     */
    public static @AuraEnabled void notifyAirports(Id tenderId, String locationType) {
        AITM_DeBriefEmailGenerator.AirportEmailGenerator emailCreator = new AITM_DeBriefEmailGenerator.AirportEmailGenerator(tenderId,locationType);
        List<AITM_EmailGeneratorController.EmailDTO> generatedEmails = emailCreator.getAirportEmails();
        if(generatedEmails !=null){
            new AITM_EmailGeneratorController().sendEmail(generatedEmails);
        }
    }

    /**
     * @description attaches email
     * @param  emailDTOWithTenderId of type string
     * @return void
     */
    public static @AuraEnabled void attachEmail(String emailDTOWithTenderId, String locationType) {
        EmailDTOTenderId dataObject = (EmailDTOTenderId) JSON.deserialize(emailDTOWithTenderId, EmailDTOTenderId.class);
        AITM_DeBriefEmailGenerator.AttachmentGenerator emailAsAttachmentGenerator = 
		    new AITM_DeBriefEmailGenerator.AttachmentGenerator(dataObject.tenderId, dataObject.emailDTO, locationType);
        emailAsAttachmentGenerator.attach();
    }

    /**
     * @description wrapper class EmailDTOTenderId
     */
    private @testVisible class EmailDTOTenderId {
        public Id tenderId;
        public AITM_EmailGeneratorController.EmailDTO emailDTO;
    }
}
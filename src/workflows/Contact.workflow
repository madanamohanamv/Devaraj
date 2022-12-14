<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CALCF_UpdateContactDeduplicationId</fullName>
        <description>CA:LCF - Populates the Contact Deduplication Id with a concatentation of First Name, Last Name and Email address (in upper case)</description>
        <field>Contact_Deduplication_Id__c</field>
        <formula>UPPER(FirstName &amp; LastName &amp; Email)</formula>
        <name>CALCF_UpdateContactDeduplicationId</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CA_RemoveFaxNumber</fullName>
        <description>CA:SFO, LCF - Removes any value from Fax number - used when Fax is invalid</description>
        <field>Fax</field>
        <name>CA_RemoveFaxNumber</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CALCF_HasCastrolContactFirstNameLastNameOrEmailChanged</fullName>
        <actions>
            <name>CALCF_UpdateContactDeduplicationId</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>CA: LCF - Checks if the Contact is related directly to a Castrol Account and if the First Name, Last Name or Email Address of the contact has changed. Used to populate Contact.DeduplicationId</description>
        <formula>OR(     AND(OR(Account.RecordType.DeveloperName = &apos;Customer&apos;,            Account.RecordType.DeveloperName = &apos;Prospect&apos;),    ISNEW()) ,    AND(OR(Account.RecordType.DeveloperName = &apos;Customer&apos;,            Account.RecordType.DeveloperName = &apos;Prospect&apos;),    OR(ISCHANGED(FirstName),    ISCHANGED(LastName),    ISCHANGED(Email))) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CA_RemoveInvalidFaxNumber</fullName>
        <actions>
            <name>CA_RemoveFaxNumber</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>CA: SFO, LCF - Removes any invalid fax number from Contact record - prevents errors with Siebel when Fax is coped from Account on Contact creation</description>
        <formula>AND(     OR(         Account.RecordType.DeveloperName = &apos;Customer&apos;,         Account.RecordType.DeveloperName = &apos;Prospect&apos;      ),     NOT(ISNULL(Fax)) ,     (LEFT(Fax, 1) &lt;&gt; &quot;+&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

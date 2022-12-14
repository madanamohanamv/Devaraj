<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_Location_Manager</fullName>
        <description>Notify Location Manager</description>
        <protected>false</protected>
        <recipients>
            <field>AITM_Location_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/AITM_SendToLocationManager</template>
    </alerts>
    <fieldUpdates>
        <fullName>AITM_Update_Tender_Location_Name</fullName>
        <field>Name</field>
        <formula>AITM_IATA_ICAO__c</formula>
        <name>AITM Update Tender Location Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AITM_Update_the_Location_size</fullName>
        <field>AITM_Location_Size__c</field>
        <formula>AITM_Location__r.AITM_Location_Size__c</formula>
        <name>Update the Location size</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>AITM Populate Tender Location</fullName>
        <actions>
            <name>AITM_Update_the_Location_size</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>NOT(ISNULL(AITM_Location__r.AITM_Location_Size__c ))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>AITM_Update_Tender_ Location_Name</fullName>
        <actions>
            <name>AITM_Update_Tender_Location_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>As per AR-1625 Update the creation of tender location.</description>
        <formula>NOT(ISBLANK(AITM_IATA_ICAO__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Status Changed To Awaiting Price</fullName>
        <actions>
            <name>Notify_Location_Manager</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>AITM_Tender_Location__c.AITM_Status__c</field>
            <operation>equals</operation>
            <value>Awaiting price</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>

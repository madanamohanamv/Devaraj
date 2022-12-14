<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CALCF_LowNPSEmailAlert</fullName>
        <description>CALCF_LowNPSEmailAlert</description>
        <protected>false</protected>
        <recipients>
            <field>Operations_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>castrolcustomerfeedb@bp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Live_Customer_Feedback_Templates/Low_Survey_Score_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>CALCF_ResponseNumberConversion</fullName>
        <description>CA:LCF - converts the value from the Response__c field into the the ResponseNumber if it is a numeric value</description>
        <field>lcf_ResponseNumber__c</field>
        <formula>IF(ISNUMBER(Response__c),VALUE(Response__c),NULL)</formula>
        <name>CALCF_ResponseNumberConversion</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CALCF_UpdateResponseNumber</fullName>
        <actions>
            <name>CALCF_ResponseNumberConversion</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>CA:LCF - If the user has responded to a question that is not free text then copy the number into the ResponseNumber field</description>
        <formula>AND(ISNUMBER(Response__c),lcf_Question_Type__c&lt;&gt;&quot;Free Text&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>

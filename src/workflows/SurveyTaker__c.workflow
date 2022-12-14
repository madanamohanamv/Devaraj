<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CALCF_ComplaintSurveyEmail</fullName>
        <description>CALCF_ComplaintSurveyEmail</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>castrolcustomerfeedb@bp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Live_Customer_Feedback_Templates/LCF_Survey_Template</template>
    </alerts>
    <alerts>
        <fullName>CALCF_SurveyEmail</fullName>
        <description>CALCF_SurveyEmail</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>castrolcustomerfeedb@bp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Live_Customer_Feedback_Templates/LCF_Survey_Template</template>
    </alerts>
    <alerts>
        <fullName>CALCF_SurveyReminder</fullName>
        <description>CALCF_SurveyReminder</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>castrolcustomerfeedb@bp.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Live_Customer_Feedback_Templates/LCF_Survey_Template_Reminder</template>
    </alerts>
    <fieldUpdates>
        <fullName>CALCF_UpdateSurveyStatus</fullName>
        <description>CA:LCF - Update status of a survey to Sent</description>
        <field>Survey_Status__c</field>
        <literalValue>Sent</literalValue>
        <name>CALCF_UpdateSurveyStatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contact_Time_Stamp_Update</fullName>
        <field>Contact_Time_Stamp__c</field>
        <formula>NOW()</formula>
        <name>Contact Time Stamp Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CALCF_CalculateContactTime</fullName>
        <actions>
            <name>Contact_Time_Stamp_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( ISCHANGED(Contact_Status__c), TEXT(Contact_Status__c) = &quot;Contacted&quot; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CALCF_SendReminderEmail</fullName>
        <actions>
            <name>CALCF_SurveyReminder</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SurveyTaker__c.Fire_Reminder__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>CA:LCF - This workflow will fire an email if Fire Reminder flag is true</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CALCF_SendSurveyEmail</fullName>
        <actions>
            <name>CALCF_SurveyEmail</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>CALCF_UpdateSurveyStatus</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SurveyTaker__c.Fire_Survey__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>CA:LCF - This workflow will fire an email if Fire flag is true</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>

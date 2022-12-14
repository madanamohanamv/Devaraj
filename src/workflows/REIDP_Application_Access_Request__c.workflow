<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CAIDP_Request_for_Application_Approve</fullName>
        <description>CAIDP Request for Application Approve</description>
        <protected>false</protected>
        <recipients>
            <field>User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>accountsteam@castrol.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CAIDP_Custom_Community_Emails/CAIDP_Access_Approval_Success</template>
    </alerts>
    <alerts>
        <fullName>CAIDP_Request_for_Application_Reject</fullName>
        <description>CAIDP Request for Application Reject</description>
        <protected>false</protected>
        <recipients>
            <field>User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>accountsteam@castrol.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CAIDP_Custom_Community_Emails/CAIDP_Access_Approval_Rejection</template>
    </alerts>
    <fieldUpdates>
        <fullName>REIDP_Access_Approval_Date_Expired</fullName>
        <field>Request_Expired__c</field>
        <literalValue>1</literalValue>
        <name>REIDP Access Approval Date Expired</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>REIDP_Access_Status_Approve</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>REIDP Access Status Approve</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>REIDP_Access_Status_Reject</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>REIDP Access Status Reject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>REIDP Access Approval Limit</fullName>
        <active>true</active>
        <criteriaItems>
            <field>REIDP_Application_Access_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>REIDP_Application_Access_Request__c.Request_Expired__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>REIDP_Access_Approval_Date_Expired</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>REIDP_Application_Access_Request__c.CreatedDate</offsetFromField>
            <timeLength>15</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>

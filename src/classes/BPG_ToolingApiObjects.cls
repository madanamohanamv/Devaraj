/*
* Repository of tooling api objects with some custom attributes.
*/
public class BPG_ToolingApiObjects {

    public class FlowCoverageResult extends FlowTestCoverage {
        @AuraEnabled
        public Id FlowId;
        @AuraEnabled
        public String MasterLabel;
        @AuraEnabled
        public Integer VersionNumber;
        @AuraEnabled
        public String ProcessType;
    }

    public class FlowApexTestStats extends FlowTestCoverage {
        @AuraEnabled
        public String MasterLabel {
            get {
                return FlowVersion.MasterLabel;
            }
        }

        @AuraEnabled
        public String ProcessType {
            get {
                return FlowVersion.ProcessType;
            }
        }

        @AuraEnabled
        public String ApexClass {
            get {
                return ApexTestClass.Name;
            }
        }

        @AuraEnabled
        public Integer VersionNumber {
            get {
                return FlowVersion.VersionNumber;
            }
        }
    }

    public virtual class FlowTestCoverage {
        @AuraEnabled
        public Id Id;
        @AuraEnabled
        public Id ApexTestClassId;
        @AuraEnabled
        public ApexClass ApexTestClass;
        @AuraEnabled
        public String FlowVersionId;
        @AuraEnabled
        public Flow FlowVersion;
        @AuraEnabled
        public Integer NumElementsCovered;
        @AuraEnabled
        public Integer NumElementsNotCovered;
        @AuraEnabled
        public String TestMethodName;

        @AuraEnabled
        public Integer TotalElements {
            get {
                return NumElementsCovered + NumElementsNotCovered;
            }
        }

        @AuraEnabled
        public Decimal PercentCovered {
            get {
                return (TotalElements > 0 ? (((Decimal)NumElementsCovered / (Decimal)TotalElements)) : 0);
            }
        }
    }

    public class FlowElementTestCoverage {
        @AuraEnabled
        public Id Id;
        @AuraEnabled
        public String ElementName;
        @AuraEnabled
        public Id FlowTestCoverageId;
        @AuraEnabled
        public FlowTestCoverage FlowTestCoverage;
        @AuraEnabled
        public Id FlowVersionId;
        @AuraEnabled
        public Flow FlowVersion;
        @AuraEnabled
        public String ApexClass;
        @AuraEnabled
        public String TestMethodName;
    }

    public class ApexClass {
        @AuraEnabled
        public Id Id;
        @AuraEnabled
        public String Name;
    }

    public class Flow {
        @AuraEnabled
        public Id Id;
        @AuraEnabled
        public String DefinitionId;
        @AuraEnabled
        public FlowDefinition Definition;
        @AuraEnabled
        public String Description;
        @AuraEnabled
        public String MasterLabel;
        @AuraEnabled
        public String ProcessType;
        @AuraEnabled
        public String Status;
        @AuraEnabled
        public Integer VersionNumber;
    }

    public class FlowDefinition {
        @AuraEnabled
        public Flow ActiveVersion;
        @AuraEnabled
        public String ActiveVersionId;
        @AuraEnabled
        public String DeveloperName;
        @AuraEnabled
        public Flow LatestVersion;
        @AuraEnabled
        public String LatestVersionId;
        @AuraEnabled
        public String MasterLabel;
    }
}
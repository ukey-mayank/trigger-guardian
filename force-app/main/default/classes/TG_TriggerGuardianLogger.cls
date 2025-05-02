public without sharing class TG_TriggerGuardianLogger {
    public static void logExecution(String objectName, String event, String status, String errorMsg) {
        // Check if the current user has permission to create the log record
        if (!Schema.SObjectType.Trigger_Execution_Log__c.isCreateable()) {
            System.debug('User does not have permission to create a Trigger_Execution_Log__c record');
            return;
        }

        // Create log record
        Trigger_Execution_Log__c log = new Trigger_Execution_Log__c(
            Object_Name__c = objectName,
            Event_Type__c = event,
            Execution_Status__c = status,
            Error_Message__c = errorMsg,
            Timestamp__c = System.now()
        );

        // Check Field-Level Security (FLS) before performing DML
        if (!hasFieldAccess('Object_Name__c') || 
            !hasFieldAccess('Event__c') || 
            !hasFieldAccess('Status__c') || 
            !hasFieldAccess('Error_Message__c') || 
            !hasFieldAccess('Timestamp__c')) {
            System.debug('User does not have permission to write one or more fields on Trigger_Execution_Log__c');
            return;
        }

        // Perform DML insert
        try {
            insert log;
        } catch (DmlException e) {
            System.debug('DML operation failed: ' + e.getMessage());
        }
    }

    // Helper method to check field-level access
    private static Boolean hasFieldAccess(String fieldName) {
        return Schema.sObjectType.Trigger_Execution_Log__c.fields.getMap().get(fieldName).getDescribe().isAccessible();
    }
}

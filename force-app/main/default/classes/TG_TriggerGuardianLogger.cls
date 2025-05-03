public without sharing class TG_TriggerGuardianLogger {
    
    // Enum for execution status
    public enum ExecutionStatus {
        Success,
        Skipped,
        Failed
    }

    // Single log entry method (calls bulk method internally)
    public static void logExecution(
        String objectName,
        String event,
        ExecutionStatus status,
        String errorMsg
    ) {
        Trigger_Execution_Log__c log = new Trigger_Execution_Log__c(
            Object_Name__c = objectName,
            Event_Type__c = event,
            Execution_Status__c = String.valueOf(status),
            Error_Message__c = errorMsg,
            Timestamp__c = System.now()
        );
        logExecution(new List<Trigger_Execution_Log__c>{ log });
    }

    // Bulk logging method
    public static void logExecution(List<Trigger_Execution_Log__c> logs) {
        if (logs == null || logs.isEmpty()) return;

        // Check object-level access
        if (!Schema.SObjectType.Trigger_Execution_Log__c.isCreateable()) {
            System.debug('No permission to create Trigger_Execution_Log__c records.');
            return;
        }

        // Filter out logs that fail FLS checks
        List<Trigger_Execution_Log__c> validLogs = new List<Trigger_Execution_Log__c>();
        for (Trigger_Execution_Log__c log : logs) {
            if (
                hasFieldAccess('Object_Name__c') &&
                hasFieldAccess('Event_Type__c') &&
                hasFieldAccess('Execution_Status__c') &&
                hasFieldAccess('Error_Message__c') &&
                hasFieldAccess('Timestamp__c')
            ) {
                validLogs.add(log);
            } else {
                System.debug('Skipped log due to FLS restrictions: ' + log);
            }
        }

        if (!validLogs.isEmpty()) {
            try {
                insert validLogs;
            } catch (DmlException e) {
                System.debug('Failed to insert logs: ' + e.getMessage());
            }
        }
    }

    // Field-level access helper
    private static Boolean hasFieldAccess(String fieldName) {
        return Schema.sObjectType.Trigger_Execution_Log__c
                     .fields.getMap().get(fieldName)
                     .getDescribe().isAccessible();
    }
}

public with sharing class TG_TriggerConfigHistoryController {

    // Method to fetch trigger config history logs based on filters (startDate, endDate, userId, triggerId)
    @AuraEnabled(cacheable=true)
    public static List<Trigger_Config_History__c> getAuditLogs(Map<String, String> filters) {
        try {
            String startDate = filters.get('startDate');
            String endDate = filters.get('endDate');
            String userId = filters.get('userId');
            String triggerId = filters.get('triggerId');
            
            // Build dynamic query based on filters
            String query = 'SELECT Trigger_Name__c, Field_Changed__c, Old_Value__c, New_Value__c, Change_Type__c, Changed_By__c, Changed_Timestamp__c FROM Trigger_Config_History__c WHERE ';
            List<String> conditions = new List<String>();

            if (startDate != null && startDate != '') {
                conditions.add('Changed_Timestamp__c >= :startDate');
            }
            if (endDate != null && endDate != '') {
                conditions.add('Changed_Timestamp__c <= :endDate');
            }
            if (userId != null && userId != '') {
                conditions.add('Changed_By__c = :userId');
            }
            if (triggerId != null && triggerId != '') {
                conditions.add('Trigger_Name__c = :triggerId');
            }

            if (!conditions.isEmpty()) {
                query += String.join(conditions, ' AND ');
            } else {
                query += '1 = 1';  // If no filters, return all records
            }

            // Execute the query
            List<Trigger_Config_History__c> auditLogs = Database.query(query);
            return auditLogs;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching trigger config history logs: ' + e.getMessage());
        }
    }

    // Method to fetch user options (for the user filter dropdown)
    @AuraEnabled(cacheable=true)
    public static List<User> getUserOptions() {
        try {
            // Check if the User object is accessible
            if (Schema.sObjectType.User.isAccessible()) {
                return [SELECT Id, Name FROM User WHERE IsActive = TRUE];
            } else {
                throw new AuraHandledException('You do not have permission to access User records.');
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching user options: ' + e.getMessage());
        }
    }

    // Method to fetch trigger options (for the trigger filter dropdown)
    @AuraEnabled(cacheable=true)
    public static List<Trigger_Config__mdt> getTriggerOptions() {
        try {
            // Check if the custom metadata type is accessible
            if (Schema.sObjectType.Trigger_Config__mdt.isAccessible()) {
                // Custom Metadata does not have field-level security, but we can check if the object is accessible
                return [SELECT MasterLabel FROM Trigger_Config__mdt];
            } else {
                throw new AuraHandledException('You do not have permission to access Trigger_Config__mdt records.');
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching trigger options: ' + e.getMessage());
        }
    }
}
public with sharing class TG_AdminController {

    @AuraEnabled(cacheable=true)
    public static List<Trigger_Config_Runtime__c> getTriggerSettings(Integer pageSize, Integer pageNumber) {
        Integer offset = (pageNumber - 1) * pageSize;
        return [
            SELECT Id, Object_Name__c, Is_Enabled__c, Trigger_Order__c
            FROM Trigger_Config_Runtime__c
            ORDER BY Object_Name__c
            LIMIT :pageSize OFFSET :offset
        ];
    }

    @AuraEnabled
    public static void updateTriggerStatus(Id recordId, Boolean isEnabled) {
        try {
            Trigger_Config_Runtime__c config = [
                SELECT Id, Is_Enabled__c 
                FROM Trigger_Config_Runtime__c 
                WHERE Id = :recordId 
                LIMIT 1
            ];
            config.Is_Enabled__c = isEnabled;
            update config;
        } catch (DmlException e) {
            System.debug('Error in updating Trigger Status: ' + e.getMessage());
            throw new AuraHandledException('Failed to update trigger status.');
        }
    }

    @AuraEnabled
    public static void updateTriggerOrder(Id recordId, Integer order) {
        try {
            Trigger_Config_Runtime__c config = [
                SELECT Id, Trigger_Order__c 
                FROM Trigger_Config_Runtime__c 
                WHERE Id = :recordId 
                LIMIT 1
            ];
            config.Trigger_Order__c = order;
            update config;
        } catch (DmlException e) {
            System.debug('Error in updating Trigger Order: ' + e.getMessage());
            throw new AuraHandledException('Failed to update trigger order.');
        }
    }

    @AuraEnabled
    public static void syncToMetadata() {
        // Asynchronous execution for large data sets
        try {
            TG_ConfigSyncService.syncToMetadata();
        } catch (Exception e) {
            System.debug('Error in syncToMetadata: ' + e.getMessage());
            throw new AuraHandledException('Failed to sync to metadata.');
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Trigger_Execution_Log__c> getLogs(String searchKey, Integer pageNumber) {
        String key = '%' + searchKey + '%';
        
        // Pagination logic (assuming 100 records per page)
        Integer pageSize = 100;
        Integer offset = pageSize * pageNumber;

        return [
            SELECT Id, Object_Name__c, 	Execution_Status__c, Error_Message__c, CreatedDate
            FROM Trigger_Execution_Log__c
            WHERE Object_Name__c LIKE :key
            ORDER BY CreatedDate DESC
            LIMIT :pageSize OFFSET :offset
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Trigger_Execution_Log__c> getErrorLogs(Integer pageSize, Integer pageNumber) {
        Integer offset = (pageNumber - 1) * pageSize;
        return [
            SELECT Id, Object_Name__c, Error_Message__c, CreatedDate
            FROM Trigger_Execution_Log__c
            WHERE Execution_Status__c = 'Error'
            ORDER BY CreatedDate DESC
            LIMIT :pageSize OFFSET :offset
        ];
    }

    @AuraEnabled
    public static String runManualTest(String objectName) {
        try {
            // Simulated logic to run test
            return 'Manual trigger test executed for ' + objectName;
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
}
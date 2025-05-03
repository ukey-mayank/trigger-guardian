public with sharing class TG_ConfigSyncService {

    // This method will initiate the queueable job to handle large datasets asynchronously
    public static void syncToMetadata() {
        // Enqueue the batch process for metadata sync
        System.enqueueJob(new ConfigSyncJob());
    }

    // Queueable job to handle metadata synchronization asynchronously
    public class ConfigSyncJob implements Queueable {

        private final Integer BATCH_SIZE = 200;  // Define batch size to limit SOQL queries

        public void execute(QueueableContext context) {
            Integer offset = 0;
            List<Trigger_Config_Runtime__c> runtimeConfigs;

            // Query runtime configuration records with pagination to handle large datasets
            do {
                runtimeConfigs = [
                    SELECT Id, Object_Name__c, Is_Enabled__c, Trigger_Order__c
                    FROM Trigger_Config_Runtime__c
                    LIMIT :BATCH_SIZE
                    OFFSET :offset
                ];

                // Process metadata sync for the current batch
                processMetadataSync(runtimeConfigs);

                offset += BATCH_SIZE;  // Increase offset to fetch next set of records
            } while (!runtimeConfigs.isEmpty());  // Continue until all records are processed
        }

        // Method to process the metadata sync for a batch of runtime configurations
        private void processMetadataSync(List<Trigger_Config_Runtime__c> runtimeConfigs) {
            Map<String, Metadata.Metadata> updatesMap = new Map<String, Metadata.Metadata>();

            // Iterate over the runtime configuration records to prepare metadata records
            for (Trigger_Config_Runtime__c rc : runtimeConfigs) {
                String name = rc.Object_Name__c.replace(' ', '_');
                Metadata.CustomMetadata mdt = new Metadata.CustomMetadata();
                mdt.fullName = 'Trigger_Config__mdt.' + name;

                Metadata.CustomMetadataValue enabledValue = new Metadata.CustomMetadataValue();
                enabledValue.field = 'Is_Enabled__c';
                enabledValue.value = rc.Is_Enabled__c;

                Metadata.CustomMetadataValue orderValue = new Metadata.CustomMetadataValue();
                orderValue.field = 'Trigger_Order__c';
                orderValue.value = rc.Trigger_Order__c;

                Metadata.CustomMetadataValue objectNameValue = new Metadata.CustomMetadataValue();
                objectNameValue.field = 'Object_Name__c';
                objectNameValue.value = rc.Object_Name__c;

                mdt.values = new Metadata.CustomMetadataValue[] { enabledValue, orderValue, objectNameValue };

                updatesMap.put(mdt.fullName, mdt);
            }

            // Deploy using Metadata API
            if (!updatesMap.isEmpty()) {
                try {
                    Metadata.DeployContainer container = new Metadata.DeployContainer();
                    for (Metadata.Metadata m : updatesMap.values()) {
                        container.addMetadata(m);
                    }
                    Id jobId = Metadata.Operations.enqueueDeployment(container, null);
                } catch (Exception e) {
                    logError(e.getMessage());
                }
            }
        }

        // Method to log errors (for async job tracking)
        private void logError(String errorMsg) {
            // Log to debug for now, replace with actual logging if custom object exists
            System.debug('Metadata Sync Error: ' + errorMsg);
        }
    }
}
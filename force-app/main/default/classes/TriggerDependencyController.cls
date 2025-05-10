public with sharing class TriggerDependencyController {
    @AuraEnabled(cacheable=true)
    public static String getTriggerDependencies() {
        try {
            // Mocking trigger dependency data for now (replace with real logic)
            List<Map<String, Object>> nodes = new List<Map<String, Object>>();
            List<Map<String, Object>> links = new List<Map<String, Object>>();

            nodes.add(new Map<String, Object>{ 'id' => 'AccountTrigger', 'label' => 'Account Trigger', 'group' => 'Account', 'details' => 'Handles account-related logic' });
            nodes.add(new Map<String, Object>{ 'id' => 'ContactTrigger', 'label' => 'Contact Trigger', 'group' => 'Contact', 'details' => 'Handles contact-related logic' });
            nodes.add(new Map<String, Object>{ 'id' => 'OpportunityTrigger', 'label' => 'Opportunity Trigger', 'group' => 'Opportunity', 'details' => 'Handles opportunity-related logic' });

            links.add(new Map<String, Object>{ 'source' => 'AccountTrigger', 'target' => 'ContactTrigger', 'value' => 1 });
            links.add(new Map<String, Object>{ 'source' => 'AccountTrigger', 'target' => 'OpportunityTrigger', 'value' => 1 });

            Map<String, Object> graphData = new Map<String, Object>{ 'nodes' => nodes, 'links' => links };
            return JSON.serialize(graphData);
        } catch (Exception e) {
            System.debug('Error fetching trigger dependencies: ' + e.getMessage());
            throw new AuraHandledException('Error fetching trigger dependencies: ' + e.getMessage());
        }
    }
}
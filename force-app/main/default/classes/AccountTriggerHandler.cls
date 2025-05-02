public with sharing class AccountTriggerHandler extends TG_AbstractTriggerHandler {
	public override void beforeInsert(List<SObject> newList) {
        // Implement logic for before insert on Account
    }
    
    public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
        // Implement logic for before update on Account
    }
    
    public override void beforeDelete(List<SObject> oldList) {
        // Implement logic for before delete on Account
    }
    
    public override void afterInsert(List<SObject> newList) {
        // Implement logic for after insert on Account
    }
    
    public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
        // Implement logic for after update on Account
    }
    
    public override void afterDelete(List<SObject> oldList) {
        // Implement logic for after delete on Account
    }
}
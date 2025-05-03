public with sharing class ContactTriggerHandler extends TG_AbstractTriggerHandler{
	public override void beforeInsert(List<SObject> newList) {
        // Implement logic for before insert on Contact
    }
    
    public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
        // Implement logic for before update on Contact
    }
    
    public override void beforeDelete(List<SObject> oldList) {
        // Implement logic for before delete on Contact
    }
    
    public override void afterInsert(List<SObject> newList) {
        // Implement logic for after insert on Contact
    }
    
    public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
        // Implement logic for after update on Contact
    }
    
    public override void afterDelete(List<SObject> oldList) {
        // Implement logic for after delete on Contact
    }
    public override void afterUndelete(List<SObject> newList) {
        // Implement logic for after undelete on Account
    }
}
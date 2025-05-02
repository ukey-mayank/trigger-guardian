public abstract class TG_AbstractTriggerHandler {
    public virtual void beforeInsert(List<SObject> newList) {}
    public virtual void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {}
    public virtual void beforeDelete(List<SObject> oldList) {}

    public virtual void afterInsert(List<SObject> newList) {}
    public virtual void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {}
    public virtual void afterDelete(List<SObject> oldList) {}
    public virtual void afterUndelete(List<SObject> newList) {}
}
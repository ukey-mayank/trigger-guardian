trigger ContactTrigger on Contact (
    before insert, before update, before delete,
    after insert, after update, after delete,
    after undelete
) {
    TG_TriggerGuardianDispatcher.dispatch('Contact', Trigger.operationType);
}

import { LightningElement, track, wire } from 'lwc';
import getAuditLogs from '@salesforce/apex/TG_TriggerConfigHistoryController.getAuditLogs';
import getUserOptions from '@salesforce/apex/TG_TriggerConfigHistoryController.getUserOptions';
import getTriggerOptions from '@salesforce/apex/TG_TriggerConfigHistoryController.getTriggerOptions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TriggerGuardianConfigHistory extends LightningElement {
    startDate;
    endDate;
    selectedUser = '';
    selectedTrigger = '';
    auditLogs = [];
    userOptions = [];
    triggerOptions = [];
    loading = false;

    // Define columns for lightning-datatable
    columns = [
        { label: 'Trigger Name', fieldName: 'Trigger_Name__c' },
        { label: 'Field Changed', fieldName: 'Field_Changed__c' },
        { label: 'Old Value', fieldName: 'Old_Value__c' },
        { label: 'New Value', fieldName: 'New_Value__c' },
        { label: 'Change Type', fieldName: 'Change_Type__c' },
        { label: 'Changed By', fieldName: 'Changed_By__c' },
        { label: 'Timestamp', fieldName: 'Changed_Timestamp__c' },
    ];

    connectedCallback() {
        this.initializeData();
    }

    initializeData() {
        this.loading = true;
        Promise.all([this.fetchUserOptions(), this.fetchTriggerOptions(), this.fetchAuditLogs()])
            .then(() => this.loading = false)
            .catch(error => {
                this.loading = false;
                this.showErrorToast('Error initializing data');
                console.error(error);
            });
    }

    fetchUserOptions() {
        return getUserOptions()
            .then(data => {
                this.userOptions = data.map(user => ({ label: user.Name, value: user.Id }));
            })
            .catch(error => {
                this.showErrorToast('Error fetching user options');
                console.error(error);
            });
    }

    fetchTriggerOptions() {
        return getTriggerOptions()
            .then(data => {
                this.triggerOptions = data.map(trigger => ({ label: trigger.DeveloperName, value: trigger.DeveloperName }));
            })
            .catch(error => {
                this.showErrorToast('Error fetching trigger options');
                console.error(error);
            });
    }

    fetchAuditLogs() {
        this.loading = true;
        const filters = {
            startDate: this.startDate,
            endDate: this.endDate,
            userId: this.selectedUser,
            triggerId: this.selectedTrigger
        };
        getAuditLogs({ filters })
            .then(data => {
                this.auditLogs = data;
                this.loading = false;
            })
            .catch(error => {
                this.loading = false;
                this.showErrorToast('Error fetching audit logs');
                console.error(error);
            });
    }

    handleStartDateChange(event) {
        this.startDate = event.target.value;
        this.fetchAuditLogs();
    }

    handleEndDateChange(event) {
        this.endDate = event.target.value;
        this.fetchAuditLogs();
    }

    handleUserChange(event) {
        this.selectedUser = event.target.value;
        this.fetchAuditLogs();
    }

    handleTriggerChange(event) {
        this.selectedTrigger = event.target.value;
        this.fetchAuditLogs();
    }

    showErrorToast(message) {
        const event = new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error'
        });
        this.dispatchEvent(event);
    }
}
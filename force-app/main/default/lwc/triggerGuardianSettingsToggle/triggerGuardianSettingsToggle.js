import { LightningElement, wire, track } from 'lwc';
import getTriggerSettings from '@salesforce/apex/TG_AdminController.getTriggerSettings';
import updateTriggerStatus from '@salesforce/apex/TG_AdminController.updateTriggerStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TriggerGuardianSettingsToggle extends LightningElement {
    @track settings = [];
    @track isLoading = false;
    @track errorMessage = '';

    connectedCallback() {
        this.fetchSettings();
    }

    async fetchSettings() {
        this.isLoading = true;
        try {
            const data = await getTriggerSettings({ pageSize: 100, pageNumber: 1 }); // Optional pagination
            this.settings = JSON.parse(JSON.stringify(data)); // Deep clone to avoid mutation issues
            this.errorMessage = '';
        } catch (error) {
            this.errorMessage = 'Failed to load settings.';
            console.error(error);
        } finally {
            this.isLoading = false;
        }
    }

    async handleToggle(event) {
        const id = event.target.dataset.id;
        const settingIndex = this.settings.findIndex(s => s.Id === id);

        if (settingIndex === -1) return;

        const originalValue = this.settings[settingIndex].Is_Enabled__c;
        const newValue = !originalValue;

        // Optimistic UI update
        this.settings[settingIndex].Is_Enabled__c = newValue;

        try {
            await updateTriggerStatus({ recordId: id, isEnabled: newValue });
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Trigger status updated.',
                variant: 'success'
            }));
        } catch (error) {
            // Revert the change on error
            this.settings[settingIndex].Is_Enabled__c = originalValue;
            this.errorMessage = 'Failed to update trigger status.';
            console.error(error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Failed to update trigger status.',
                variant: 'error'
            }));
        }
    }
}
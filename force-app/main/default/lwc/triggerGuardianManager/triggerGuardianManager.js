import { LightningElement, track } from 'lwc';
import getTriggerSettings from '@salesforce/apex/TG_AdminController.getTriggerSettings';
import updateTriggerStatus from '@salesforce/apex/TG_AdminController.updateTriggerStatus';
import updateTriggerOrder from '@salesforce/apex/TG_AdminController.updateTriggerOrder';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TriggerGuardianManager extends LightningElement {
    @track settings = [];
    @track isLoading = false;
    @track isSaving = false;
    @track errorMessage = '';

    draggedItemId = null;
    originalOrders = [];

    connectedCallback() {
        this.fetchSettings();
    }

    async fetchSettings() {
        this.isLoading = true;
        try {
            const data = await getTriggerSettings({ pageSize: 100, pageNumber: 1 });
            this.settings = data.map(order => ({
                ...order,
                updatedOrder: order.Trigger_Order__c
            }));
            this.originalOrders = JSON.parse(JSON.stringify(this.settings));
            this.errorMessage = '';
        } catch (error) {
            this.errorMessage = 'Failed to load trigger settings.';
            console.error(error);
        } finally {
            this.isLoading = false;
        }
    }

    handleToggle(event) {
        const id = event.target.dataset.id;
        const settingIndex = this.settings.findIndex(s => s.Id === id);
        if (settingIndex === -1) return;

        const originalValue = this.settings[settingIndex].Is_Enabled__c;
        const newValue = !originalValue;

        this.settings[settingIndex].Is_Enabled__c = newValue;

        updateTriggerStatus({ recordId: id, isEnabled: newValue })
            .then(() => {
                this.showToast('Success', 'Trigger status updated.', 'success');
            })
            .catch(error => {
                this.settings[settingIndex].Is_Enabled__c = originalValue;
                console.error(error);
                this.showToast('Error', 'Failed to update trigger status.', 'error');
            });
    }

    handleOrderChange(event) {
        const recordId = event.target.dataset.id;
        const newOrder = parseInt(event.target.value, 10);
        this.settings = this.settings.map(order => {
            if (order.Id === recordId) {
                return { ...order, updatedOrder: newOrder };
            }
            return order;
        });
    }

    handleReset() {
        this.settings = JSON.parse(JSON.stringify(this.originalOrders));
    }

    handleSaveOrder() {
        this.isSaving = true;
        const updates = this.settings.map(order => ({
            Id: order.Id,
            Trigger_Order__c: order.updatedOrder
        }));

        updateTriggerOrder({ updatedOrders: updates })
            .then(() => {
                this.showToast('Success', 'Trigger order updated successfully.', 'success');
                this.originalOrders = JSON.parse(JSON.stringify(this.settings));
            })
            .catch(error => {
                console.error('Failed to update trigger order', error);
                this.showToast('Error', 'Failed to update trigger orders', 'error');
            })
            .finally(() => {
                this.isSaving = false;
            });
    }

    handleDragStart(event) {
        this.draggedItemId = event.currentTarget.dataset.id;
    }

    handleDragOver(event) {
        event.preventDefault();
    }

    handleDrop(event) {
        const droppedItemId = event.currentTarget.dataset.id;
        if (this.draggedItemId === droppedItemId) return;

        const draggedIndex = this.settings.findIndex(item => item.Id === this.draggedItemId);
        const droppedIndex = this.settings.findIndex(item => item.Id === droppedItemId);

        const updatedList = [...this.settings];
        const [draggedItem] = updatedList.splice(draggedIndex, 1);
        updatedList.splice(droppedIndex, 0, draggedItem);

        updatedList.forEach((item, index) => {
            item.updatedOrder = index + 1;
        });

        this.settings = updatedList;
    }

    handleDragEnd() {
        this.draggedItemId = null;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant
        }));
    }
}
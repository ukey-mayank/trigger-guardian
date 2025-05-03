import { LightningElement, wire, track } from 'lwc';
import getTriggerSettings from '@salesforce/apex/TG_AdminController.getTriggerSettings';
import updateTriggerOrder from '@salesforce/apex/TG_AdminController.updateTriggerOrder';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TriggerGuardianExecutionOrderManager extends LightningElement {
    @track triggerOrders = [];
    originalOrders = [];
    isSaving = false;
    isLoading = true;
    showNoData = false;
    errorMessage = '';

    draggedItemId = null;

    @wire(getTriggerSettings)
    wiredOrders({ error, data }) {
        this.isLoading = false;
        if (data && data.length > 0) {
            this.triggerOrders = data.map(order => ({
                ...order,
                updatedOrder: order.Trigger_Order__c
            }));
            this.originalOrders = JSON.parse(JSON.stringify(this.triggerOrders));
        } else if (data && data.length === 0) {
            this.showNoData = true;
        } else if (error) {
            console.error('Error fetching orders:', error);
            this.errorMessage = 'Failed to load trigger orders.';
        }
    }

    handleOrderChange(event) {
        const recordId = event.target.dataset.id;
        const newOrder = parseInt(event.target.value, 10);
        this.triggerOrders = this.triggerOrders.map(order => {
            if (order.Id === recordId) {
                return { ...order, updatedOrder: newOrder };
            }
            return order;
        });
    }

    handleReset() {
        this.triggerOrders = JSON.parse(JSON.stringify(this.originalOrders));
    }

    handleSave() {
        this.isSaving = true;
        const updates = this.triggerOrders.map(order => ({
            Id: order.Id,
            Trigger_Order__c: order.updatedOrder
        }));

        updateTriggerOrder({ updatedOrders: updates })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Trigger order updated successfully',
                        variant: 'success'
                    })
                );
                this.originalOrders = JSON.parse(JSON.stringify(this.triggerOrders));
            })
            .catch(error => {
                console.error('Failed to update trigger order', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Failed to update trigger orders',
                        variant: 'error'
                    })
                );
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

        const draggedIndex = this.triggerOrders.findIndex(item => item.Id === this.draggedItemId);
        const droppedIndex = this.triggerOrders.findIndex(item => item.Id === droppedItemId);

        const updatedList = [...this.triggerOrders];
        const [draggedItem] = updatedList.splice(draggedIndex, 1);
        updatedList.splice(droppedIndex, 0, draggedItem);

        updatedList.forEach((item, index) => {
            item.updatedOrder = index + 1;
        });

        this.triggerOrders = updatedList;
    }

    handleDragEnd() {
        this.draggedItemId = null;
    }
}
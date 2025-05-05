import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLogs from '@salesforce/apex/TG_AdminController.getLogs';
import deleteLogRecord from '@salesforce/apex/TG_AdminController.deleteLogRecord';

export default class TriggerGuardianExecutionLog extends NavigationMixin(LightningElement) {
    @track logs = [];
    @track searchTerm = '';
    @track isLoading = false;
    @track errorMessage = '';
    @track hasMoreData = true;
    @track nextPage = 0;

    @track startDate = '';
    @track endDate = '';
    @track statusFilter = '';

    columns = [
        { label: 'Object Name', fieldName: 'Object_Name__c' },
        { label: 'Status', fieldName: 'Execution_Status__c' },
        { label: 'Error Message', fieldName: 'Error_Message__c' },
        { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'View Record', name: 'view' },
                    { label: 'Delete Log', name: 'delete' }
                ]
            }
        }
    ];

    statusOptions = [
        { label: 'All', value: '' },
        { label: 'Success', value: 'Success' },
        { label: 'Failure', value: 'Failure' },
        { label: 'Skipped', value: 'Skipped' }
    ];

    connectedCallback() {
        this.fetchLogs();
    }

    handleInputChange(event) {
        this.searchTerm = event.target.value;
    }

    handleSearchKeydown(event) {
        if (event.key === 'Enter') {
            this.resetAndFetch();
        }
    }

    handleDateChange(event) {
        const field = event.target.dataset.id;
        if (field === 'startDate') {
            this.startDate = event.target.value;
        } else if (field === 'endDate') {
            this.endDate = event.target.value;
        }
    }

    handleStatusChange(event) {
        this.statusFilter = event.detail.value;
        console.log('Execution Status selected:', this.statusFilter);
    }

    applyFilters() {
        this.resetAndFetch();
    }

    resetAndFetch() {
        this.logs = [];
        this.nextPage = 0;
        this.hasMoreData = true;
        this.fetchLogs();
    }

    fetchLogs() {
        this.isLoading = true;
    
        // Format start and end dates if they exist
        let formattedStart = this.startDate ? this.formatDate(this.startDate) : null;
        let formattedEnd = this.endDate ? this.formatDate(this.endDate) : null;
    
        // Log formatted dates for debugging
        console.log('Formatted Start Date:', formattedStart);
        console.log('Formatted End Date:', formattedEnd);
    
        // Validate formatted date strings
        if (formattedStart && !this.isValidDateFormat(formattedStart)) {
            this.errorMessage = 'Invalid start date format';
            this.isLoading = false;
            return;
        }
    
        if (formattedEnd && !this.isValidDateFormat(formattedEnd)) {
            this.errorMessage = 'Invalid end date format';
            this.isLoading = false;
            return;
        }
    
        // Construct filter object to match Apex LogFilter class
        const filter = {
            searchKey: this.searchTerm,
            pageNumber: this.nextPage,
            startDate: formattedStart,
            endDate: formattedEnd,
            executionStatus: this.statusFilter
        };
    
        console.log('Final filter sent to Apex:', JSON.stringify(filter));
        // Call Apex method with a single 'filter' object
        getLogs({ filter })
            .then((data) => {
                if (this.nextPage === 0) {
                    this.logs = data;
                } else {
                    this.logs = [...this.logs, ...data];
                }
    
                this.hasMoreData = data.length === 50;
                this.isLoading = false;
            })
            .catch((error) => {
                this.errorMessage = 'Error fetching logs: ' + (error.body?.message || error.message);
                this.isLoading = false;
            });
    }    
    
    // Helper method to check if the date format is valid (YYYY-MM-DD)
    isValidDateFormat(dateStr) {
        const datePattern = /^\d{4}-\d{2}-\d{2}$/; // YYYY-MM-DD format
        return datePattern.test(dateStr);
    }    

    formatDate(dateStr) {
        try {
            // Check if the input is a valid date string
            const dateObj = new Date(dateStr);
    
            // Check if the dateObj is valid
            if (isNaN(dateObj.getTime())) {
                return null; // Return null if the date is invalid
            }
    
            // Return the date in 'YYYY-MM-DD' format
            return dateObj.toISOString().split('T')[0];
        } catch (e) {
            return null; // Return null if there is any other error
        }
    }    

    loadMoreLogs() {
        if (this.isLoading || !this.hasMoreData) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'No More Logs',
                    message: 'There are no additional logs to load.',
                    variant: 'info',
                    mode: 'dismissable'
                })
            );
            return;
        }

        this.nextPage++;
        this.fetchLogs();
    }

    deleteLog(recordId) {
        this.isLoading = true;
        deleteLogRecord({ recordId })
            .then(() => {
                this.logs = this.logs.filter(log => log.Id !== recordId);
                this.isLoading = false;
            })
            .catch(error => {
                this.errorMessage = 'Error deleting log: ' + (error.body?.message || error.message);
                this.isLoading = false;
            });
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        switch (actionName) {
            case 'view':
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.Id,
                        actionName: 'view'
                    }
                });
                break;

            case 'delete':
                this.deleteLog(row.Id);
                break;
        }
    }

    get noLogsFound() {
        return this.logs.length === 0 && !this.isLoading;
    }
}
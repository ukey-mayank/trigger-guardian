import { LightningElement, track } from 'lwc';
import getLogsWithErrorFilter from '@salesforce/apex/TG_AdminController.getLogsWithErrorFilter';
import getErrorLogs from '@salesforce/apex/TG_AdminController.getErrorLogs';

export default class TriggerGuardianLogsPanel extends LightningElement {
    @track logs = [];
    @track errors = [];
    @track isLoading = false;
    @track errorMessage = '';
    @track searchTerm = '';
    @track startDate = '';
    @track endDate = '';
    @track statusFilter = '';
    @track noLogsFound = false;
    @track showNoErrors = false;

    // Pagination for Execution Logs
    @track pageSize = 10;
    @track currentPage = 1;
    @track totalRecords = 0;

    // Columns for Lightning Datatable
    get columns() {
        return [
            { label: 'Log ID', fieldName: 'Id' },
            { label: 'Object Name', fieldName: 'Object_Name__c' },
            { label: 'Execution Status', fieldName: 'Execution_Status__c' },
            { label: 'Error Message', fieldName: 'Error_Message__c' },
            { label: 'Timestamp', fieldName: 'CreatedDate' }
        ];
    }

    // Options for Execution Status Filter
    get statusOptions() {
        return [
            { label: 'All', value: '' },
            { label: 'Success', value: 'Success' },
            { label: 'Failure', value: 'Failure' }
        ];
    }

    // Lifecycle Hook - On Load, fetch logs
    connectedCallback() {
        this.loadExecutionLogs();
        this.loadErrorLogs();
    }

    // Handle Changes for Filters
    handleInputChange(event) {
        this.searchTerm = event.target.value;
    }

    handleDateChange(event) {
        const fieldName = event.target.dataset.id;
        if (fieldName === 'startDate') {
            this.startDate = event.target.value;
        } else if (fieldName === 'endDate') {
            this.endDate = event.target.value;
        }
    }

    handleStatusChange(event) {
        this.statusFilter = event.target.value;
    }

    // Apply Filters to Execution Logs
    applyFilters() {
        this.currentPage = 1;
        this.loadExecutionLogs();
    }

    // Fetch Execution Logs with Filters and Pagination
    async loadExecutionLogs() {
        this.isLoading = true;
        this.errorMessage = '';
        this.noLogsFound = false;
        try {
            const data = await getLogsWithErrorFilter({
                searchTerm: this.searchTerm,
                startDate: this.startDate,
                endDate: this.endDate,
                statusFilter: this.statusFilter,
                pageSize: this.pageSize,
                currentPage: this.currentPage
            });

            if (data && data.logs) {
                this.logs = data.logs;
                this.totalRecords = data.totalRecords;
                this.noLogsFound = this.logs.length === 0;
            } else {
                this.logs = [];
                this.totalRecords = 0;
                this.noLogsFound = true;
            }
        } catch (error) {
            this.errorMessage = 'Failed to load execution logs.';
            console.error(error);
        } finally {
            this.isLoading = false;
        }
    }

    // Load More Execution Logs (Pagination)
    loadMoreLogs() {
        if (this.logs.length < this.totalRecords) {
            this.currentPage++;
            this.loadExecutionLogs();
        }
    }

    // Fetch Error Logs
    async loadErrorLogs() {
        this.isLoading = true;
        this.errorMessage = '';
        this.showNoErrors = false;
        try {
            const data = await getErrorLogs();
            this.errors = data || [];
            this.showNoErrors = this.errors.length === 0;
        } catch (error) {
            this.errorMessage = 'Failed to load error logs.';
            console.error(error);
        } finally {
            this.isLoading = false;
        }
    }
}
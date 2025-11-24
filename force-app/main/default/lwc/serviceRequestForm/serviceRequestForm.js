import { LightningElement, wire } from 'lwc';
import createServiceRequests from '@salesforce/apex/ServiceRequestController.createServiceRequests';
import getRecentServiceRequests from '@salesforce/apex/ServiceRequestController.getRecentServiceRequests';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class ServiceRequestForm extends LightningElement {
    // ---- Form State ----
    customerEmail = '';
    description = '';
    priority = '';
    createdRequestId;
    errorMessage;
    isLoading = false;

    // ---- Recent Requests Data ----
    wiredRecentRequestsResult;
    recentRequestsData;

    // ---- Datatable Columns ----
    columns = [
        {
            label: 'Name',
            fieldName: 'recordLink',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'Name' },
                target: '_blank'
            }
        },
        { label: 'Email', fieldName: 'Customer_Email__c' },
        { label: 'Status', fieldName: 'Status__c' },
        { label: 'Priority', fieldName: 'Priority__c' }
    ];

    // ---- Priority Options ----
    get priorityOptions() {
        return [
            { label: 'Low', value: 'Low' },
            { label: 'Medium', value: 'Medium' },
            { label: 'High', value: 'High' }
        ];
    }

    // ---- Wire Apex ----
    @wire(getRecentServiceRequests)
    recentRequests(result) {
        this.wiredRecentRequestsResult = result;

        if (result.data) {
            this.recentRequestsData = result.data.map(sr => ({
                ...sr,
                recordLink: '/' + sr.Id
            }));
        } else if (result.error) {
            this.recentRequestsData = undefined;
        }
    }

    // ---- Input Handler ----
    handleChange(event) {
        const field = event.target.dataset.name;
        const value = event.detail?.value ?? event.target.value;

        if (field && field in this) {
            this[field] = value;
        }
    }

    // ---- Form Validation ----
    validateForm() {
        const fields = this.template.querySelectorAll(
            'lightning-input[data-name="customerEmail"], ' +
            'lightning-textarea[data-name="description"], ' +
            'lightning-combobox[data-name="priority"]'
        );

        let allValid = true;

        fields.forEach(field => {
            const isFieldValid = field.reportValidity(); // shows error if invalid
            if (!isFieldValid) {
                allValid = false;
            }
        });

        return allValid;
    }

    // ---- Submit Handler ----
    async handleSubmit() {
        this.errorMessage = null;
        this.createdRequestId = null;

        const isValid = this.validateForm();
        if (!isValid) {
            this.errorMessage = 'Please correct the errors before submitting.';
            return;
        }

        this.isLoading = true;

        const inputs = [
            {
                customerEmail: this.customerEmail,
                description: this.description,
                priority: this.priority
            }
        ];

        try {
            const result = await createServiceRequests({ inputs });

            if (result && result.length > 0) {
                this.createdRequestId = result[0].Id;

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Service Request created successfully.',
                        variant: 'success'
                    })
                );

                // Reset form
                this.customerEmail = '';
                this.description = '';
                this.priority = '';

                // Refresh datatable
                if (this.wiredRecentRequestsResult) {
                    await refreshApex(this.wiredRecentRequestsResult);
                }
            }
        } catch (error) {
            let message = 'An error occurred while creating the Service Request.';

            if (error?.body?.message) {
                message = error.body.message;
            } else if (Array.isArray(error?.body)) {
                message = error.body.map(e => e.message).join(', ');
            }

            this.errorMessage = message;

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message,
                    variant: 'error'
                })
            );
        } finally {
            this.isLoading = false;
        }
    }
}

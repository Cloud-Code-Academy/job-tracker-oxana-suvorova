import { LightningElement, api, track, wire } from 'lwc';
import getTaxDeduction from '@salesforce/apex/TakeHomePayEstimatorController.getTaxDeduction';
import getTaxesAndPayChecks from '@salesforce/apex/TakeHomePayEstimatorController.getTaxesAndPayChecks';
import updateJobApplication from '@salesforce/apex/TakeHomePayEstimatorController.updateJobApplication';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { getRecord, getFieldValue, notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import SALARY_FIELD from '@salesforce/schema/Job_Application__c.Salary__c';

const fields = [SALARY_FIELD];

export default class TakeHomePayEstimator extends LightningElement {
    @api recordId;
    annualIncome = 100000;
    recordPage = false;

    @wire(getRecord, { recordId: '$recordId', fields: fields })
    wiredRecord({ error, data }) {
        if (data) {
            this.annualIncome = getFieldValue(data, SALARY_FIELD);
            this.error = undefined;
            this.recordPage = true;
        } else if (error) {
            this.error = error.body.message;
        }
    }

    filingStatus = 'Single';
    standardDeduction = 0;
    federalTaxValue = 0;
    socialSecurity = 0;
    medicare = 0;

    @track needCalculate = true;
    @track error;

    get taxableIncome() {
        return this.annualIncome - this.standardDeduction;
    }

    get annualPaycheck() {
        return this.annualIncome - this.federalTaxValue - this.socialSecurity - this.medicare;
    }

    get monthlyPaycheck() {
        return this.annualPaycheck / 12;
    }

    filingStatusOptions = [
        { label: 'Single', value: 'Single' },
        { label: 'Married, filing jointly', value: 'MarriedFJointly' },
        { label: 'Married, filing separately', value: 'MarriedFSeparately' },
        { label: 'Head of household', value: 'HeadOfHousehold' }
    ];

    @wire(getTaxDeduction, { filingStatus: '$filingStatus' } )
    setStandardDeduction({ error, data }) {
        if (data) {
            this.standardDeduction = data;
            this.error = undefined;
            this.needCalculate = true;
        } else if (error) {
            this.error = error.body.message;
        }
    };

    annualIncomeChange(event) {
        this.annualIncome = event.target.value;
        this.needCalculate = true;
    }

    filingStatusChange(event) {
        this.filingStatus = event.target.value;
    }

    async handleEstimateClick() {
        // Create the object with parameters with
        // the shape of the Apex TakeHomePayWrapper class
        const takeHomePayParameters = {
            annualIncome: this.annualIncome,
            filingStatus: this.filingStatus,
            taxableIncome: this.taxableIncome
        };
        // Calculate Taxes and Paycheck
        try {
            const calcResults = await getTaxesAndPayChecks({ wrapper: takeHomePayParameters });
            this.error = undefined;
            this.federalTaxValue = calcResults['federalTaxValue'];
            this.socialSecurity = calcResults['socialSecurity'];
            this.medicare = calcResults['medicare'];
        } catch (error) {
            this.error = error.body.message;
        }
        this.needCalculate = false;
    }

    async handleUpdateJobAppClick() {
        // Create the object with parameters with
        // the shape of the Apex TakeHomePayWrapper class
        const takeHomePayResults = {
            federalTaxValue: this.federalTaxValue,
            socialSecurity: this.socialSecurity,
            medicare: this.medicare,
            annualPaycheck: this.annualPaycheck,
            monthlyPaycheck: this.monthlyPaycheck
        };
        try {
            await updateJobApplication({
                recordId: this.recordId,
                wrapper: takeHomePayResults
            });
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Job Application record updated',
                    variant: 'success'
                })
            );
            notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }
    }
}
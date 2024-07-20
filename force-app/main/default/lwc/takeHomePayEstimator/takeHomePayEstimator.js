import { LightningElement, track, wire } from 'lwc';
import getTaxDeduction from '@salesforce/apex/TakeHomePayEstimatorController.getTaxDeduction';
import getTaxesAndPayChecks from '@salesforce/apex/TakeHomePayEstimatorController.getTaxesAndPayChecks';

export default class TakeHomePayEstimator extends LightningElement {
    annualIncome = 100000;
    filingStatus = 'Single';
    standardDeduction = 0;
    federalTaxValue = 0;
    socialSecurity = 0;
    medicare = 0;

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

    annualIncomeChange(event) {
        this.annualIncome = event.target.value;
    }

    filingStatusChange(event) {
        this.filingStatus = event.target.value;
    }

    @wire(getTaxDeduction, { filingStatus: '$filingStatus', isFederal: true } )
    setStandardDeduction({ error, data }) {
        if (data) {
            this.standardDeduction = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
        }
        
    };

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
            this.federalTaxValue = 0;
            this.socialSecurity = 0;
            this.medicare = 0;
            this.error = error;
        }
    }
}
import { LightningElement, track, wire } from 'lwc';
// import getTaxDeductions from '@salesforce/apex/TakeHomePayEstimatorController.getTaxDeductions';
import getTaxDeduction from '@salesforce/apex/TakeHomePayEstimatorController.getTaxDeduction';

export default class TakeHomePayEstimator extends LightningElement {
    annualIncome = 100000;
    filingStatus = 'Single';
    standardDeduction = 0;
    // deductionsList;
    @track error;

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
        } else if (error) {
            this.error = error;
        }
    };

    // connectedCallback() {
    //     getTaxDeductions()
    //         .then(result => {
    //             this.deductionsList = result;
    //             this.error = undefined;
    //         })
    //         .catch(error => {
    //             this.error = error;
    //             this.deductionsList = undefined;
    //         });
    // }

}
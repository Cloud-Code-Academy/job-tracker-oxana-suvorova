import { LightningElement, track, wire } from 'lwc';
import getTaxDeduction from '@salesforce/apex/TakeHomePayEstimatorController.getTaxDeduction';
import getTaxBrackets from '@salesforce/apex/TakeHomePayEstimatorController.getTaxBrackets';

export default class TakeHomePayEstimator extends LightningElement {
    annualIncome = 100000;
    filingStatus = 'Single';
    standardDeduction = 0;
    taxableIncome;
    federalTaxValue = 0;

    @track error;

    filingStatusOptions = [
        { label: 'Single', value: 'Single' },
        { label: 'Married, filing jointly', value: 'MarriedFJointly' },
        { label: 'Married, filing separately', value: 'MarriedFSeparately' },
        { label: 'Head of household', value: 'HeadOfHousehold' }
    ];

    @wire(getTaxBrackets, { filingStatus: '$filingStatus' } )
    taxBrackets;

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
            this.taxableIncome = this.annualIncome - this.standardDeduction;
        } else if (error) {
            this.error = error;
        }
        
    };

    handleEstimateClick() {
        for (const bracket of this.taxBrackets.data) {
            if (this.taxableIncome > bracket.Min_Bracket__c) {
                this.federalTaxValue = (this.taxableIncome - bracket.Min_Bracket__c) * bracket.Tax_Rate__c + bracket.Tax_Value__c;
                break;
            }
        }
    }
}
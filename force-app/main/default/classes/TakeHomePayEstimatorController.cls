public with sharing class TakeHomePayEstimatorController {

    @AuraEnabled(cacheable=true)
    public static Decimal getTaxDeduction(String filingStatus, Boolean isFederal) {
        List<Tax_Deduction__mdt> taxDeductions = [
            SELECT
                Filing_status__c,
                isFederal__c,
                Deduction__c
            FROM Tax_Deduction__mdt
            WHERE isFederal__c = :isFederal
            AND Filing_status__c = :filingStatus
        ];
        if (taxDeductions.size() > 0) {
            return taxDeductions[0].Deduction__c;
        } else {
            throw new AuraHandledException('Tax Deductions are not specified!');
        }
    }

    /**
    * @description Performs Tax calculations and Paycheck based on the parameters from the LWC.
    * @param wrapper: The values are based on the data that is defined in the takeHomePayEstimator LWC.
    * @return: the Map of the calculated Tax vales by it's Name. 
    **/
    @AuraEnabled(cacheable=true)
    public static Map<String, Decimal> getTaxesAndPayChecks(TakeHomePayWrapper wrapper){
        Map<String, Decimal> results = new Map<String, Decimal>();

        // Federal Tax
        Decimal federalTaxValue = 0;
        List<Federal_Tax_Bracket__mdt> taxBrackets = getTaxBrackets(wrapper.filingStatus);
        for (Federal_Tax_Bracket__mdt bracket : taxBrackets) {
            if (wrapper.taxableIncome > bracket.Min_Bracket__c) {
                federalTaxValue = (wrapper.taxableIncome - bracket.Min_Bracket__c) * bracket.Tax_Rate__c + bracket.Tax_Value__c;
                break;
            }
        }
        results.put('federalTaxValue', federalTaxValue);
        
        // Social Security and Medicare
        Decimal socialSecurity = 0;
        Decimal medicare = 0;
        Map<String, Other_Tax__mdt> otherTaxrates = getOtherTaxRates();
        if (otherTaxrates.size() > 0) {
            Other_Tax__mdt medicareData = otherTaxrates.get('Medicare');
            medicare = wrapper.annualIncome * medicareData.Tax_Rate__c / 100;
            Other_Tax__mdt socialSecurityData = otherTaxrates.get('SocialSecurity');
            Decimal socialSecurityBase = 0;
            if (wrapper.annualIncome < socialSecurityData.Taxable_Maximum__c) {
                socialSecurityBase = wrapper.annualIncome;
            } else {
                socialSecurityBase = socialSecurityData.Taxable_Maximum__c;
            }
            socialSecurity = socialSecurityBase * socialSecurityData.Tax_Rate__c / 100;
        }
        results.put('medicare', medicare);
        results.put('socialSecurity', socialSecurity);

        if (results.size() > 0) {
            return results;
        } else {
            throw new AuraHandledException('Something went wrong: Can not calculate Taxes with specified parameters!');
        }
    }
    
    public static List<Federal_Tax_Bracket__mdt> getTaxBrackets(String filingStatus) {
        return [
            SELECT
                Filing_status__c,
                Min_Bracket__c,
                Tax_Rate__c,
                Tax_Value__c,
                Calculation_order__c
            FROM Federal_Tax_Bracket__mdt
            WHERE Filing_status__c = :filingStatus
            ORDER BY Calculation_order__c ASC
        ];
    }

    public static Map<String, Other_Tax__mdt> getOtherTaxRates() {
        return Other_Tax__mdt.getAll();
    }
}
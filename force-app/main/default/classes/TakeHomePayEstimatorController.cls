public with sharing class TakeHomePayEstimatorController {

    /**
    * @description Returns Federal Tax Deduction by the Filing Status. 
    * @param filingStatus: The string that specifies filing status.
    * @return: Decimal number. Value of the Federal Tax Deduction. 
    **/
    @AuraEnabled(cacheable=true)
    public static Decimal getTaxDeduction(String filingStatus) {
        List<Tax_Deduction__mdt> taxDeductions = [
            SELECT
                Filing_status__c,
                Deduction__c
            FROM Tax_Deduction__mdt
            WHERE Filing_status__c = :filingStatus
        ];
        return taxDeductions[0].Deduction__c;
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

        return results;
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

    @AuraEnabled
    public static void updateJobApplication(Id recordId, TakeHomePayWrapper wrapper, String filingStatus){
        try {
            if (!Schema.SObjectType.Job_Application__c.isUpdateable()) {
                throw new SecurityException(
                    'You can not update Job Application record'
                );
            }
            Job_Application__c jobApp = new Job_Application__c(
                Id = recordId,
                Federal_Income_Tax__c = wrapper.federalTaxValue,
                Social_Security__c = wrapper.socialSecurity,
                Medicare_Withholding__c = wrapper.medicare,
                Annual_Take_home_Pay__c = wrapper.annualPaycheck,
                Monthly_Take_home_Pay__c = wrapper.monthlyPaycheck,
                Filing_status__c = filingStatus
            );
            Database.update(jobApp);
        } catch (SecurityException ex) {
            String message = ex.getMessage();
            AuraHandledException auraEx = new AuraHandledException(message);
            auraEx.setMessage(message);
            throw auraEx;
        }
    }
}
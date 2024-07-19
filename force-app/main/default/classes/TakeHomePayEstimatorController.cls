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

    @AuraEnabled(cacheable=true)
    public static List<Federal_Tax_Bracket__mdt> getTaxBrackets(String filingStatus) {
        List<Federal_Tax_Bracket__mdt> taxBrackets = [
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
        if (taxBrackets.size() > 0) {
            return taxBrackets;
        } else {
            throw new AuraHandledException('Tax Brackets are not specified!');
        }
    }
}
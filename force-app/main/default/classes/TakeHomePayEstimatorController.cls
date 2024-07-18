public with sharing class TakeHomePayEstimatorController {
    
    // @AuraEnabled(cacheable=true)
    // public static List<Tax_Deduction__mdt> getTaxDeductions() {
    //     List<Tax_Deduction__mdt> taxDeductions = [
    //         SELECT
    //             Filing_status__c,
    //             isFederal__c,
    //             Deduction__c
    //         FROM Tax_Deduction__mdt
    //     ];
    //     if (taxDeductions.size() > 0) {
    //         return taxDeductions;
    //     } else {
    //         throw new AuraHandledException('Tax Deductions are not specified!');
    //     }
    // }

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
}
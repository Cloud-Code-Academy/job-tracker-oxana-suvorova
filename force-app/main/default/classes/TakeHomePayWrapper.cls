/**
 * Wrapper class used to pass paramters from takeHomepayEstimator LWC to calculate tax values and paychecks.
 */
public with sharing class TakeHomePayWrapper {
    @AuraEnabled
    public Double annualIncome { get; set; }
    @AuraEnabled
    public String filingStatus { get; set; }
    @AuraEnabled
    public Double taxableIncome { get; set; }
    @AuraEnabled
    public Double federalTaxValue { get; set; }
    @AuraEnabled
    public Double socialSecurity { get; set; }
    @AuraEnabled
    public Double medicare { get; set; }
    @AuraEnabled
    public Double annualPaycheck { get; set; }
    @AuraEnabled
    public Double monthlyPaycheck { get; set; }
}
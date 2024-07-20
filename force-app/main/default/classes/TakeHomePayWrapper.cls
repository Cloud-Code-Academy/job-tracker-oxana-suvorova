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
}
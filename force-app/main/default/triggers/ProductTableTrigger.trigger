trigger ProductTableTrigger on ProductTable__c (before insert, before update) {
    ProductTableTriggerHelper.checkAvailabilityAndSetAddedDate(Trigger.new); 
}
public with sharing class ProductTableTriggerHelper {
    public static void checkAvailabilityAndSetAddedDate(List<ProductTable__c> prods) {
        for(ProductTable__c a : prods) {
            if(a.Amount__c > 0){
                a.Available__c = true;
            } else {
                a.Available__c = false;
            }
            a.AddedDate__c = Date.today();
        }
    }
}
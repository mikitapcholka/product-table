public with sharing class ProductTableController {
    @AuraEnabled
    public static List<ProductTable__c> getProducts() {
        return [
            SELECT 
                Id, 
                Name, 
                Amount__c, 
                Price__c, 
                ProductType__c, 
                ReleaseDate__c, 
                Available__c
            FROM ProductTable__c
            WITH SECURITY_ENFORCED
            ORDER BY AddedDate__c DESC
            LIMIT 2000
        ];
    }
}    
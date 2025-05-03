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

    @AuraEnabled
    public static List<ProductTable__c> addProduct(String addedRecord) {
        ProductTable__c recordToAdd = (ProductTable__c) JSON.deserialize(addedRecord, ProductTable__c.class);
        ProductTable__c newRecord = new ProductTable__c(
                Name = recordToAdd.Name,
                Amount__c = recordToAdd.Amount__c,
                Price__c = recordToAdd.Price__c,
                ProductType__c = recordToAdd.ProductType__c,   
                ReleaseDate__c = recordToAdd.ReleaseDate__c
        );

        insert newRecord;   
        
        return getProducts();        
    }

    @AuraEnabled
    public static List<ProductTable__c> editProduct(String editedRecord) {
        ProductTable__c recordToEdit = (ProductTable__c) JSON.deserialize(editedRecord, ProductTable__c.class);
        ProductTable__c findRecordToEdit = [
            SELECT 
                Id, 
                Name, 
                Amount__c, 
                Price__c, 
                ProductType__c, 
                ReleaseDate__c
            FROM ProductTable__c
            WHERE Id = :recordToEdit.Id
            WITH SECURITY_ENFORCED
        ];
        findRecordToEdit.Name = recordToEdit.Name;
        findRecordToEdit.Amount__c = recordToEdit.Amount__c;
        findRecordToEdit.Price__c = recordToEdit.Price__c;
        findRecordToEdit.ProductType__c = recordToEdit.ProductType__c;
        findRecordToEdit.ReleaseDate__c = recordToEdit.ReleaseDate__c;

        update findRecordToEdit;   
        
        return getProducts();        
    }

    @AuraEnabled
    public static List<ProductTable__c> deleteProduct(String deletedRecord) {
        ProductTable__c recordToDelete = (ProductTable__c) JSON.deserialize(deletedRecord, ProductTable__c.class);
        ProductTable__c findRecordToDelete = [
            SELECT 
                Id,
                Name
            FROM ProductTable__c
            WHERE Id = :recordToDelete.Id
            WITH SECURITY_ENFORCED
        ];

        delete findRecordToDelete;   
        
        return getProducts();        
    }
}    
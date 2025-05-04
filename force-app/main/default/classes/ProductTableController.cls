public with sharing class ProductTableController {
    private static final Integer DEFAULT_PAGE_SIZE = 10;
    private static final Set<String> PRODUCT_FIELDS = new Set<String>{
        'Id',
        'Name',
        'Amount__c',
        'Price__c',
        'ProductType__c',
        'ReleaseDate__c',
        'Available__c'
    };

    @AuraEnabled
    public static ResultData getProducts(
        String searchTerm,
        String orderField,
        String orderDirection,
        Integer pageSize,
        Integer pageNumber
    ) {
        WithoutSharings ws = new WithoutSharings();
        return ws.getProductsWS(searchTerm, orderField, orderDirection, pageSize, pageNumber);
    }

    public without sharing class WithoutSharings {
        public ResultData getProductsWS(
            String searchTerm,
            String orderField,
            String orderDirection,
            Integer pageSize,
            Integer pageNumber
        ) {
                ResultData result = new ResultData();

                String soql = 'SELECT ' + String.join(PRODUCT_FIELDS, ', ') + ' FROM ProductTable__c ';
                String countSoql = 'SELECT COUNT() FROM ProductTable__c ';

                if (String.isNotBlank(searchTerm)) {
                    soql += ' WHERE Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\' ';
                    countSoql += ' WHERE Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\' ';
                }

                soql += ' WITH SECURITY_ENFORCED ';
                countSoql += ' WITH SECURITY_ENFORCED';

                if (
                    String.isNotBlank(orderField) 
                    && String.isNotBlank(orderDirection)
                    && PRODUCT_FIELDS.contains(orderField)
                    && (new Set<String>{'ASC', 'DESC'}).contains(orderDirection)
                ) {
                    soql += ' ORDER BY ' + String.escapeSingleQuotes(orderField) + ' ' + String.escapeSingleQuotes(orderDirection) + ' ';
                } else {
                    soql += ' ORDER BY AddedDate__c DESC ';
                }

                if (pageSize == null || pageSize < 1 || pageSize > 1000) {
                    pageSize = DEFAULT_PAGE_SIZE;
                }
                soql += ' LIMIT ' + pageSize;

                Integer offset = pageNumber * pageSize;
                if (offset > 2000) {
                    offset = 2000;
                }
                soql += ' OFFSET ' + offset;

                System.debug(soql);

                result.products = (List<ProductTable__c>)Database.query(soql);
                result.totalRecords = Database.countQuery(countSoql);

                return result;
        }}

    public class ResultData {
        @AuraEnabled public List<ProductTable__c> products {get; set;}
        @AuraEnabled public Integer totalRecords {get; set;}
    }

    @AuraEnabled
    public static void addProduct(String addedRecord) {
        ProductTable__c recordToAdd = (ProductTable__c) JSON.deserialize(addedRecord, ProductTable__c.class);
        ProductTable__c newRecord = new ProductTable__c(
                Name = recordToAdd.Name,
                Amount__c = recordToAdd.Amount__c,
                Price__c = recordToAdd.Price__c,
                ProductType__c = recordToAdd.ProductType__c,   
                ReleaseDate__c = recordToAdd.ReleaseDate__c
        );

        insert newRecord;                    
    }

    @AuraEnabled
    public static void editProduct(String editedRecord) {
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
    }

    @AuraEnabled
    public static void deleteProduct(String deletedRecord) {
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
    }
}    
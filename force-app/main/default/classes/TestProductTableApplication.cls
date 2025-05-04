/*
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestProductTableApplication {

   @isTest
    static void addTest() {
        String searchTerm = 'Product';
        String orderField = 'Name';
        String orderDirection = 'asc';
        Integer pageSize = 5;
        Integer pageNumber = 0;

        String addedRecord = '{"Name":"New Product","Amount__c":50,"Price__c":5000,"ProductType__c":"Phone","ReleaseDate__c":"2025-05-01"}';
        String toCheck = '"Name":"New Product","Amount__c":50,"Price__c":5000,"ProductType__c":"Phone","ReleaseDate__c":"2025-05-01","Available__c":true';

        Test.startTest();
        ProductTableController.addProduct(addedRecord);
        ProductTableController.ResultData result = 
            ProductTableController.getProducts(searchTerm, orderField, orderDirection, pageSize, pageNumber);
        Test.stopTest();

        String res = JSON.serialize(result.products);
        boolean check = res.contains(toCheck);
        Assert.isTrue(check, 'addTest failure');

    }

    @isTest
    static void editTest() {
        ProductTable__c newProduct = new ProductTable__c(
            Name = 'Default Product',
            Amount__c = 50,
            Price__c = 5000,
            ProductType__c = 'Phone',
            ReleaseDate__c = Date.valueOf('2025-05-01')
        );

        insert newProduct;

        String searchTerm;
        String orderField;
        String orderDirection;
        Integer pageSize = 5;
        Integer pageNumber = 0;

        String editedRecord = '{"Id":'+JSON.serialize(newProduct.Id)+',"Name":"Edited Product","Amount__c":0,"Price__c":4000,"ProductType__c":"Camera","ReleaseDate__c":"2025-05-03"}';
        String toCheck = '"Name":"Edited Product","Amount__c":0,"Price__c":4000,"ProductType__c":"Camera","ReleaseDate__c":"2025-05-03","Available__c":false'; 

        Test.startTest();
            ProductTableController.editProduct(editedRecord);
            ProductTableController.ResultData result = 
            ProductTableController.getProducts(searchTerm, orderField, orderDirection, pageSize, pageNumber);
        Test.stopTest();

        String res = JSON.serialize(result.products);
        boolean check = res.contains(toCheck);
        Assert.isTrue(check, 'editTest failure');
    }

    @isTest
    static void deleteTest() {
        ProductTable__c newProduct = new ProductTable__c(
            Name = 'Default Product',
            Amount__c = 50,
            Price__c = 5000,
            ProductType__c = 'Phone',
            ReleaseDate__c = Date.valueOf('2025-05-01')
        );

        insert newProduct;

        String searchTerm;
        String orderField;
        String orderDirection;
        Integer pageSize = 5;
        Integer pageNumber = 0;

        String deletedRecord = '{"Id":'+JSON.serialize(newProduct.Id)+',"Name":"Default Product","Amount__c":50,"Price__c":5000,"ProductType__c":"Phone","ReleaseDate__c":"2025-05-01"}';
        String toCheck = '"Name":"Default Product"'; 

        Test.startTest();
            ProductTableController.deleteProduct(deletedRecord);
            ProductTableController.ResultData result = 
            ProductTableController.getProducts(searchTerm, orderField, orderDirection, pageSize, pageNumber);
        Test.stopTest();

        String res = JSON.serialize(result.products);
        boolean check = res.contains(toCheck);
        Assert.isFalse(check, 'editTest failure');

    }
}
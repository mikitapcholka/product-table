import { track, LightningElement } from 'lwc';
import getProducts from "@salesforce/apex/ProductTableController.getProducts";
import addProduct from "@salesforce/apex/ProductTableController.addProduct";
import editProduct from "@salesforce/apex/ProductTableController.editProduct";
import deleteProduct from "@salesforce/apex/ProductTableController.deleteProduct";
export default class ProductTable extends LightningElement {
    @track products;
    @track isShowAddWindow = false;
    @track isShowEditWindow = false;
    @track isShowDeleteWindow = false;
    @track currentProd;

    //--------------------------------------------------------------------------------------

    connectedCallback() {
        getProducts()
            .then(result => {                
                this.products = result;
            })
            .catch(e => {
                console.error(e);
            })
    }

    handleChangeInput(e) {
        this.currentProd[e.target.dataset.field] = e.target.value;
    }

    //--------------------------------------------------------------------------------------

    get options() {
        return [
            { label: 'Camera', value: 'Camera' },
            { label: 'Phone', value: 'Phone' },
            { label: 'Clock', value: 'Clock' },
            { label: 'Tablet', value: 'Tablet' },
        ];
    }

    //--------------------------------------------------------------------------------------

    showAddWindow() { 
        this.currentProd = {
            Id: 1,
            Name: '',
            Amount__c: '',
            Price__c: '',
            ProductType__c: '',
            ReleaseDate__c: '',
        };
        this.isShowAddWindow = true;
    }

    showEditWindow(e) {
        //this.currentProd = this.products.find(prod => prod.Id === e.target.dataset.id);
        this.currentProd = JSON.parse(JSON.stringify(this.products.find(prod => prod.Id === e.target.dataset.id)));
        this.isShowEditWindow = true;
    }

    showDeleteWindow(e) {  
        this.currentProd = JSON.parse(JSON.stringify(this.products.find(prod => prod.Id === e.target.dataset.id)));
        this.isShowDeleteWindow = true;
    }

    hideAddWindow() {  
        this.isShowAddWindow = false;
    }

    hideEditWindow() {  
        this.isShowEditWindow = false;
    }

    hideDeleteWindow() {  
        this.isShowDeleteWindow = false;
    }

    //--------------------------------------------------------------------------------------

    addRecord() {
        addProduct({ addedRecord: JSON.stringify(this.currentProd) })
            .then(result => {                
                this.products = result;
            })
            .catch(e => {
                console.error(e);
            });
        this.hideAddWindow();
    }

    editRecord() {
        editProduct({ editedRecord: JSON.stringify(this.currentProd) })
            .then(result => {                
                this.products = result;
            })
            .catch(e => {
                console.error(e);
            });
        this.hideEditWindow();
    }

    deleteRecord() {
        deleteProduct({ deletedRecord: JSON.stringify(this.currentProd) })
            .then(result => {                
                this.products = result;
            })
            .catch(e => {
                console.error(e);
            });
        this.hideDeleteWindow();  
    }
    
}
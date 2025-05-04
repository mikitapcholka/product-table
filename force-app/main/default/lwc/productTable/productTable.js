import { api, track, LightningElement } from 'lwc';
import getProducts from "@salesforce/apex/ProductTableController.getProducts";
import addProduct from "@salesforce/apex/ProductTableController.addProduct";
import editProduct from "@salesforce/apex/ProductTableController.editProduct";
import deleteProduct from "@salesforce/apex/ProductTableController.deleteProduct";

const PAGE_SIZE_OPTIONS = [{label:"1", value:1}, {label:"2", value:2}, {label:"3", value:3}, {label:"4", value:4}, {label:"5", value:5}];
export default class ProductTable extends LightningElement {
    @api linkToDetail;
    @api columnSize;

    searchTerm;
    pageSize = 5;
    pageNumber = 0;
    totalRecords;

    pageSizeOptions = PAGE_SIZE_OPTIONS;

    @track products;
    @track isShowAddWindow = false;
    @track isShowEditWindow = false;
    @track isShowDeleteWindow = false;
    @track currentProd;
    @track isLoading;

    @track columns = [
        {label: "Name", apiName: "Name", sortAvailable: true, sortEnabled: false, sortDirection: null, sortIcon: null},
        {label: "Amount", apiName: "Amount__c", sortAvailable: true, sortEnabled: false, sortDirection: null, sortIcon: null},
        {label: "Price", apiName: "Price__c", sortAvailable: true, sortEnabled: false, sortDirection: null, sortIcon: null},
        {label: "Product Type", apiName: "ProductType__c", sortAvailable: true, sortEnabled: false, sortDirection: null, sortIcon: null},
        {label: "Release Date", apiName: "Release Date__c", sortAvailable: true, sortEnabled: false, sortDirection: null, sortIcon: null},
        {label: "Available", apiName: "Available__c", sortAvailable: false, sortEnabled: false, sortDirection: null, sortIcon: null},
        {label: "Control", apiName: null, sortAvailable: false, sortEnabled: false, sortDirection: null, sortIcon: null}
    ];

    get visiblePageNumber() {
        return this.pageNumber + 1;
    }

    get lastPageNumber() {
        return Math.ceil(this.totalRecords / this.pageSize) - 1;
    }

    get columnClass() {
        return `slds-col slds-size_${this.columnSize}-of-12`;
    }

    get orderField() {
        return  this.columns.find(column => column.sortEnabled)?.apiName;
    }

    get orderDirection() {
        return this.columns.find(column => column.sortEnabled)?.sortDirection;
    }

    get options() {
        return [
            { label: 'Camera', value: 'Camera' },
            { label: 'Phone', value: 'Phone' },
            { label: 'Clock', value: 'Clock' },
            { label: 'Tablet', value: 'Tablet' },
        ];
    }

    //--------------------------------------------------------------------------------------

    loadThroughSpinner(func, params, callback) {
        this.isLoading = true;
        func(params)
            .then(result => {
                callback(result);
            })
            .catch(e => {
                console.error(e);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    refresh() {
        this.loadThroughSpinner(
            getProducts,
            {
                searchTerm: this.searchTerm,
                orderField: this.orderField,
                orderDirection: this.orderDirection,
                pageSize: this.pageSize,  
                pageNumber: this.pageNumber
            },
            result => {               
                this.products = result.products;
                this.totalRecords = result.totalRecords;
            }
        )         
    }
    
    connectedCallback() {
        this.refresh();
    }

    //--------------------------------------------------------------------------------------

    toFirstPage() {
        if (this.pageNumber !== 0) {
            this.pageNumber = 0;
            this.refresh();
        }
    }

    toPreviousPage() {
        if (this.pageNumber > 0) {
            this.pageNumber--;
            this.refresh();
        }
    }

    toNextPage() {
        if (this.pageNumber < this.lastPageNumber) {
            this.pageNumber++;
            this.refresh();
        }
    }

    toLastPage() {
        if (this.pageNumber !== this.lastPageNumber) {
            this.pageNumber = this.lastPageNumber;
            this.refresh();
        }
    }

    pageNumberTimeout;
    handlePageNumberChange(e) {
        const inputPageNumber = parseInt(e.target.value, 10) - 1;
        if (inputPageNumber > this.lastPageNumber || inputPageNumber < 0) {
            e.target.value = this.pageNumber + 1;
            return;
        }

        this.pageNumberTimeout = setTimeout(() => {
            this.pageNumber = inputPageNumber;
            this.refresh();
        }, 1000);
    }

    handleChangeInput(e) {
        this.currentProd[e.target.dataset.field] = e.target.value;
    }

    handleChangePageSize(e) {
        const inputPageSize = parseInt(e.target.value, 10);
        if (inputPageSize !== this.pageSize) {
            this.pageSize = inputPageSize;
            this.pageNumber = 0;
            this.refresh();
        }
    }

    searchTimeout;
    onSearchTermChange(e) {
        this.searchTerm = e.target.value;
        clearTimeout(this.searchTimeout);
        this.searchTimeout = setTimeout(() => {
            this.pageNumber = 0;
            this.refresh();
        }, 1000);
    }

    getDataParam(el, paramName, maxInteration = 10) {
        let param = null;
        if (el.dataset[paramName]) {
            param = el.dataset[paramName];
        } else {
            if (maxInteration > 0) {
                param = this.getDataParam(el.parentElement, paramName, maxInteration - 1);
            }
        }
        return param;
    }

    handleSort(e) {
        let apiName = this.getDataParam(e.target, "field");
        if(apiName) {
            if(!this.columns.find(c => c.apiName === apiName).sortAvailable) {
                return;
            }
            this.columns.forEach(column => {
                if (column.apiName === apiName) {
                    if (column.sortEnabled) {
                        column.sortDirection = column.sortDirection === 'ASC' ? 'DESC' : 'ASC';
                    } else {
                        column.sortEnabled = true;
                        column.sortDirection = 'ASC';
                    }
                    column.sortIcon = column.sortDirection === 'ASC' ? 'utility:arrowup' : 'utility:arrowdown';
                } else {
                    if (column.sortEnabled) {
                        column.sortEnabled = false;
                        column.sortDirection = null;
                        column.sortIcon = null;
                    }
                }

            });
            this.refresh();
        }
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
        this.currentProd = JSON.parse(JSON.stringify(this.products.find(prod => prod.Id === e.target.dataset.id)));
        this.isShowEditWindow = true;
        console.log(JSON.stringify(this.currentProd));
    }

    showDeleteWindow(e) {  
        this.currentProd = JSON.parse(JSON.stringify(this.products.find(prod => prod.Id === e.target.dataset.id)));
        this.isShowDeleteWindow = true;
    }

    //Without a timeout, the data does not have time to update in the table

    refreshTimeout;

    hideAddWindow() {
        clearTimeout(this.refreshTimeout);
        this.refreshTimeout = setTimeout(() => {this.refresh()}, 1000); 
        this.isShowAddWindow = false;
    }

    hideEditWindow() {  
        clearTimeout(this.refreshTimeout);
        this.refreshTimeout = setTimeout(() => {this.refresh()}, 1000);
        this.isShowEditWindow = false;
    }

    hideDeleteWindow() {  
        clearTimeout(this.refreshTimeout);
        this.refreshTimeout = setTimeout(() => {this.refresh()}, 1000);
        this.isShowDeleteWindow = false;
    }

    //--------------------------------------------------------------------------------------

    addRecord() {
        addProduct({ addedRecord: JSON.stringify(this.currentProd) })           
        this.hideAddWindow();
    }

    editRecord() {
        editProduct({ editedRecord: JSON.stringify(this.currentProd) })   
        this.hideEditWindow();
    }

    deleteRecord() {
        deleteProduct({ deletedRecord: JSON.stringify(this.currentProd) }) 
        this.hideDeleteWindow(); 
    }
    
}
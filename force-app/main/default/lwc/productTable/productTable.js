import { track, LightningElement } from 'lwc';
import getProducts from "@salesforce/apex/ProductTableController.getProducts";

export default class ProductTable extends LightningElement {
    @track products;

    connectedCallback() {
        getProducts()
            .then(result => {                
                this.products = result;
            })
            .catch(e => {
                console.error(e);
            })
    }
}
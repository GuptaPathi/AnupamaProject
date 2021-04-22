import { LightningElement,api,track,wire } from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import CONTACT_ACCOUNT from '@salesforce/schema/Contact.AccountId';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import Level_Field from '@salesforce/schema/Contact.Level__c';

export default class ContactTable extends LightningElement {
    @api fieldSetName;
    @api objectApiName;
    @api recordId;
    
    @track filterObject={};
    @track searchClause;
    recordTypeId;
    @track levelPickList;

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    getRecordTypeId({ data, error }) {
        if (data) {
            const rtis = data.recordTypeInfos;
            this.recordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'C&P Online');
        } else if (error) {
           // this.toastMessage(this.label.UI_Text_Label_Error, result.error.body.message, 'error');
        }
    }
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: Level_Field })
    wirePickList({ data, error }) {
        if (data) {
            this.levelPickList = data.values;
        } else if (error) {
           // this.toastMessage(this.label.UI_Text_Label_Error, result.error.body.message, 'error');
        }
    }
    @wire(getRecord, { recordId:'$recordId', fields: [CONTACT_ACCOUNT]})
    loadFields({error, data}){
        console.log('loadFields, recordId: ', this.recordId);
        if(error){
            console.log('error', JSON.parse(JSON.stringify(error)));
        }else if(data){
            console.log('data', JSON.parse(JSON.stringify(data)));
            const paramField1 = getFieldValue(data, CONTACT_ACCOUNT);
            this.filterObject['AccountId'] = getFieldValue(data, CONTACT_ACCOUNT);
            this.searchClause = 'AccountId =\''+getFieldValue(data, CONTACT_ACCOUNT)+'\'';
            console.log('paramField1', paramField1);
            console.log('filterObject 22  strfg : ',JSON.stringify(this.filterObject));
        }
    }

    get searchString(){
        console.log('=======================')
        object.keys(this.filterObject).forEach(eachField=>{
            console.log(eachField,' :==========>>> ',this.filterObject[eachField]);
            return 'hai'
        })
    }
    renderedCallback(){
        console.log('filterObject strfggggggg : ',JSON.stringify(this.filterObject));
    }
    handleChange(event){
        console.log('levelyyy : ',event.target.value);
        this.filterObject[event.target.name] = event.target.value;
        this.searchClause = '';;
        Object.keys(this.filterObject).forEach(eachValue=>{
            this.searchClause += this.searchClause != ''?' AND ':'';
           if(eachValue == 'FirstName'){
            this.searchClause += eachValue+' LIKE \'%'+this.filterObject[eachValue]+'%\'';
           }else{
            this.searchClause += eachValue+' =\''+this.filterObject[eachValue]+'\'';
           }
        })
        console.log('searchClause : ',this.searchClause)
    }
}
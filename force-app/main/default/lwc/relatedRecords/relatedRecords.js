import { LightningElement,api,wire,track } from 'lwc';
import getRecords from '@salesforce/apex/RelatedRecordsController.getRecords';
export default class RelatedRecords extends LightningElement {

    @api recordId;
    @api fieldSet;
    @api filterInfo={};
    @api searchClause;
    @api sObject;
    
    @track data = [];
    @track columns = [];
    @track fieldsInfo=[];
    

    get showTable(){
        console.log('filter data : ',this.filterInfo);
        return this.data.length>0;
    }

    @wire (getRecords ,{searchClause : '$searchClause',recordId : '$recordId',sObjectName:'$sObject',fieldSetName:'$fieldSet',filterString:'$filterInfo'})
    wiredDetails ({error,data}){
        if(data){
            let fields = JSON.parse(data.FieldDetails);
            this._prepareColumns(fields);
            console.log('==hul====>> ',data.data);
            this.data = data.data!=undefined?JSON.parse(data.data):[];   
        }else if (error){

        }
    }

    _prepareColumns(fieldsArray){
        this.columns = [];
        fieldsArray.forEach(eachField=>{
            let column = {};
            column['label'] = eachField.label;
            if(eachField.type == 'reference'){
                this.fieldsInfo.push(eachField.fieldPath);
                column['fieldName']= eachField.fieldPath;
              //  column['type']='url';
              //  column['typeAttributes'] = {label: { fieldName: eachField.fieldPath.indexOf('__c') != -1?eachField.fieldPath.replace('__c','__r.Name'):eachField.fieldPath.replace('Id','.Name') },target: '_blank'}
            }else{
                column['fieldName']=eachField.fieldPath;
                column['type']=eachField.type;
            }
            this.columns.push(column);
        });
        console.log('columnslidts-rrr : ',JSON.stringify(this.columns));
    }
}
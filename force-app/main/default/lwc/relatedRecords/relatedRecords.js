import { LightningElement,api,wire,track } from 'lwc';
import getRecords from '@salesforce/apex/RelatedRecordsController.getRecords';
export default class RelatedRecords extends LightningElement {

    @api recordId;
    @api sObject='Contact';
    @api fieldSet='anupamaFS';
    @track data = [];
    @track columns = [];
    @track fieldsInfo=[];
    get showTable(){
        return this.data.length>0;
    }

    @wire (getRecords ,{recordId : '$recordId',sObjectName:'$sObject',fieldSetName:'$fieldSet'})
    wiredDetails ({error,data}){
        if(data){
            let fields = JSON.parse(data.FieldDetails);
            this._prepareColumns(fields);
            this.data = JSON.parse(data.data);            
        }else if (error){

        }
    }

    _prepareColumns(fieldsArray){
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
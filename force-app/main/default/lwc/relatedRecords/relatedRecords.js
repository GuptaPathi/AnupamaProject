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
    @track lookupColumns=[];

    get showTable(){
        console.log('filter data : ',this.filterInfo);
        return this.data.length>0;
    }

    @wire (getRecords ,{searchClause : '$searchClause',recordId : '$recordId',sObjectName:'$sObject',fieldSetName:'$fieldSet',filterString:'$filterInfo'})
    wiredDetails ({error,data}){
        if(data){
            let fields = JSON.parse(data.FieldDetails);
            this._prepareColumns(fields);
            var receivedData = data.data!=undefined?JSON.parse(data.data):[];
            var records=[];
            console.log('receivedData : ',JSON.stringify(receivedData))
            receivedData.forEach(eachRecord=>{
                var record={};
                Object.keys(eachRecord).forEach(eachField=>{
                   record[eachField] = eachRecord[eachField];
                   if(this.lookupColumns.includes(eachField)){
                    if(eachRecord[eachField] != undefined){
                        var nameField = eachField.indexOf('__c') != -1?eachField.replace('__c','__r'):eachField.replace('Id','');
                        record[eachField+'url'] = '/'+eachRecord[eachField];
                        record[eachField+'name'] = eachRecord[nameField].Name;
                    }else{
                        record[eachField+'url'] = '';
                        record[eachField+'name'] = '';
                    }
                   }
                })
                records.push(record);
            });  
            this.data = records;
            console.log('===finally=====>>>>      : ',JSON.stringify(this.data));
        }else if (error){

        }
    }

    _prepareColumns(fieldsArray){
        this.columns = [];
        fieldsArray.forEach(eachField=>{
            let column = {};
            column['label'] = eachField.label;
            if(eachField.type == 'reference'){
                this.lookupColumns.push(eachField.fieldPath);
                this.fieldsInfo.push(eachField.fieldPath);
                column['fieldName']= eachField.fieldPath+'url';
                column['type']='url';
                column['typeAttributes'] = {label: { fieldName: eachField.fieldPath+'name'},target: '_blank'}
            }else{
                column['fieldName']=eachField.fieldPath;
                column['type']=eachField.type;
            }
            this.columns.push(column);
        });
        console.log('columnslidts-rrr : ',JSON.stringify(this.columns));
    }
}
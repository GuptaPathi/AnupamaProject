public with sharing class RelatedRecordsController {
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getRecords(String searchClause,String recordId,String sObjectName,String fieldSetName,Map<String,String> filterString){
        Map<String,String> returnData = new Map<String,string>();
        system.debug('searchClause : '+searchClause);
       String soql = 'SELECT Id';
        String whereClause;
        List<Schema.FieldSetMember> fieldSetMemberList =  RelatedRecordsController.readFieldSet(fieldSetName,sObjectName);
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList){
            String apiName = fieldSetMemberObj.getFieldPath();
            if(String.valueOf(fieldSetMemberObj.getType()) == 'REFERENCE'){
                system.debug('line 14');
                String fields = apiName.indexOf('__c') != -1?apiName.replace('__c','__r.Name'):apiName.replace('Id','.Name');
            	soql += ','+fields;
            }
            soql += ','+apiName;
        }
        soql += ' From '+sObjectName;
        if(! filterString.isEmpty()){
			whereClause = ' WHERE '+searchClause;
        }
        soql += whereClause;
        system.debug('soql : '+soql);
        system.debug('soql : '+Database.query(soql));
        List<sObject> db = Database.query(soql);
        String dfd = db.size()>0?JSON.serialize(db):null;
        returnData.put('FieldDetails',JSON.serialize(fieldSetMemberList));
        returnData.put('data',dfd);
        return returnData;
        
    }
    
    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName){
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields();
	}
}
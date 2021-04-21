public with sharing class RelatedRecordsController {
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getRecords(String recordId,String sObjectName,String fieldSetName){
        Map<String,String> returnData = new Map<String,string>();
       String soql = 'SELECT Id';
        List<Schema.FieldSetMember> fieldSetMemberList =  RelatedRecordsController.readFieldSet(fieldSetName,sObjectName);
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList){
            String apiName = fieldSetMemberObj.getFieldPath();
            system.debug('API Name ====>' + fieldSetMemberObj.getFieldPath()); //api name
            system.debug('Label ====>' + fieldSetMemberObj.getLabel());
            system.debug('Required ====>' + fieldSetMemberObj.getRequired());
            system.debug('DbRequired ====>' + fieldSetMemberObj.getDbRequired());
            system.debug('Type ====>' + fieldSetMemberObj.getType());
            if(String.valueOf(fieldSetMemberObj.getType()) == 'REFERENCE'){
                system.debug('line 14');
                String fields = apiName.indexOf('__c') != -1?apiName.replace('__c','__r.Name'):apiName.replace('Id','.Name');
            	soql += ','+fields;
            }
            soql += ','+apiName;
        }
        soql += ' From '+sObjectName;
        system.debug('soql : '+Database.query(soql));
        returnData.put('FieldDetails',JSON.serialize(fieldSetMemberList));
        returnData.put('data',JSON.serialize(Database.query(soql)));
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
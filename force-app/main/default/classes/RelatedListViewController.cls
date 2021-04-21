global class RelatedListViewController extends VisualEditor.DynamicPickList {
    @AuraEnabled(cacheable=true)
    public static List<Relationship> getChildRelationshipList(
      String sObjectAPIName) {
  
      List<Relationship> relationshipList = new List<Relationship>();
      List<ChildRelationship> childRelationships = 
        Schema.getGlobalDescribe().get(sObjectAPIName).
        getDescribe().getChildrelationships();
  
      for (ChildRelationship cr : childRelationships) {
        relationshipList.add(new Relationship(
          cr.getChildSObject().getDescribe().getLabel(), 
          cr.getChildSObject().getDescribe().getName(), 
          cr.getField().getDescribe().getLabel(),
          cr.getField().getDescribe().getName()));
      }
      return relationshipList;
    }
  
    @AuraEnabled(cacheable=true)
    public static ColumnsAndOperatorsWrapper getColumnsAndOperators(
      String sObjectAPIName) {
  
      Map<String, String> allColumnMap = new Map<String, String>();
      Map<String, String> filterableColumnMap = new Map<String, String>();
      Map<String, String> operatorMap = new Map<String, String>();
      List<SObjectField> soFieldsList = Schema.getGlobalDescribe().
        get(sObjectAPIName).getDescribe().fields.getMap().values();
  
      for (SObjectField soField : soFieldsList) {
        allColumnMap.put(soField.getDescribe().getName(), 
          soField.getDescribe().getLabel());
  
        if (soField.getDescribe().isFilterable()) {
          filterableColumnMap.put(soField.getDescribe().getName() + ';' + 
            soField.getDescribe().getType(), 
            soField.getDescribe().getLabel());
        }
      }
      DescribeFieldResult operatorValues =
        sObjectType.User_List_View_Filter__c.fields.Operator__c;
  
      for (PicklistEntry ple : 
        sObjectType.User_List_View_Filter__c
        .fields.Operator__c.getPickListValues()) {
  
        operatorMap.put(ple.getValue(), ple.getLabel());
      }
      return new ColumnsAndOperatorsWrapper(allColumnMap, filterableColumnMap, 
        operatorMap);
    }
  
    global override VisualEditor.DataRow getDefaultValue() {
      User_List_View__c ulv = [select Id, Name 
                               from User_List_View__c 
                               where Type__c = 'Related List' 
                               order by CreatedDate desc limit 1];
  
      return new VisualEditor.DataRow(ulv.Name, String.valueOf(ulv.Id));
    }
  
    @AuraEnabled(cacheable=true)
    public static RelatedListInfo getRelatedListInfo(String userListViewId) {
      User_List_View__c ulv = [select Allow_Toggle_to_Unfiltered__c, 
                                      Show_New_Button__c, SObject_Name__c, 
                                      Type__c, 
                                      (select Field__c 
                                       from User_List_View_Filters__r 
                                       where Value__c = '{PARENT_ID}')
                               from User_List_View__c 
                               where Id = :userListViewId];
  
      if (ulv.Type__c != 'Related List') {
        return null;
      } else {
        String relationshipName = Schema.getGlobalDescribe().get(
          ulv.SObject_Name__c).getDescribe().fields.getMap().get(
          ulv.User_List_View_Filters__r[0].Field__c.split(';')[0])
          .getDescribe().getName();
  
        String parentSObjectAPIName = Schema.getGlobalDescribe().get(
          ulv.SObject_Name__c).getDescribe().fields.getMap().get(
          ulv.User_List_View_Filters__r[0].Field__c.split(';')[0]).
          getDescribe().getReferenceTo()[0].getDescribe().getName();
  
        String parentSObjectPluralName = Schema.getGlobalDescribe().get(
          ulv.SObject_Name__c).getDescribe().getLabelPlural();
  
        ulv.Show_New_Button__c = ulv.Show_New_Button__c && 
          Schema.getGlobalDescribe().get(ulv.SObject_Name__c).getDescribe()
          .isCreateable();
        
        return new RelatedListInfo(ulv.Allow_Toggle_to_Unfiltered__c,
          ulv.Show_New_Button__c, parentSObjectAPIName, relationshipName,
          ulv.User_List_View_Filters__r[0].Field__c.split(';')[0],
          parentSObjectPluralName, ulv.SObject_Name__c);
      }
    }
  
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getSObjectMapForRelatedList() {
      String queryableParentSObjects = 
        System.Label.Supported_sObjects_for_Custom_Related_List.replace(' ', '');
  
      Map<String, String> sObjectMap = new Map<String, String>();
      for (String sObjectAPIName : queryableParentSObjects.split(',')) {
        DescribeSObjectResult descSObjectResult = 
          Schema.getGlobalDescribe().get(sObjectAPIName).getDescribe();
        
        sObjectMap.put(descSObjectResult.getName(), 
          descSObjectResult.getLabel());
      }
      return sObjectMap;
    }
  
    global override VisualEditor.DynamicPickListRows getValues() {
      VisualEditor.DynamicPickListRows relatedListViewOptions = 
        new VisualEditor.DynamicPickListRows();
  
      for (User_List_View__c ulv : [select Id, Name 
                                    from User_List_View__c 
                                    where Type__c = 'Related List' 
                                    order by Name asc]) {
  
        relatedListViewOptions.addRow(new VisualEditor.DataRow(ulv.Name, 
          String.valueOf(ulv.Id)));
      }
      return relatedListViewOptions;
    }
  
    @AuraEnabled(cacheable=true)
    public static UserListViewAndDetailsWrapper getUserListViewAndDetails(
      Id userListViewId) {
  
      String parentFilterField = '';
      String parentSObjectAPIName = '';
      User_List_View__c ulv = [select Id, Name, Allow_Toggle_to_Unfiltered__c, 
                                      Is_Default_List_View__c,
                                      Is_Recently_Viewed_ListView__c,
                                      Show_My_Records_Only__c, 
                                      Show_New_Button__c, SObject_Name__c, 
                                      Sort_Column__c, Sort_Order__c,
                                      Type__c, 
                                      (select Field__c, Operator__c, Value__c 
                                       from User_List_View_Filters__r), 
                                      (select Name, Display_Order__c 
                                       from User_List_View_Columns__r
                                       order by Display_Order__c asc)
                               from User_List_View__c 
                               where Id = :userListViewId];
  
      for (User_List_View_Filter__c ulvf : ulv.User_List_View_Filters__r) {
        if (ulvf.Value__c == '{PARENT_ID}') {
          parentFilterField = ulvf.Field__c;
          break;
        }
      }
      if (String.isNotBlank(parentFilterField)) {
        parentSObjectAPIName = Schema.getGlobalDescribe().get(
          ulv.SObject_Name__c).getDescribe().fields.getMap().get(
          parentFilterField.split(';')[0]).getDescribe().
          getReferenceTo()[0].getDescribe().getName();
      }
      return new UserListViewAndDetailsWrapper(ulv, parentSObjectAPIName);
    }
  
    @AuraEnabled
    public static String saveUserListView(User_List_View__c userListView, 
      List<User_List_View_Filter__c> filters, 
      List<User_List_View_Column__c> columns) {
  
      if (userListView.Type__c == 'Related List') {
        List<User_List_View__c> ulvs = [select Id 
                                        from User_List_View__c 
                                        where Name = :userListView.Name 
                                        and Type__c = 'Related List'];
  
        if (!ulvs.isEmpty() && userListView.Id != ulvs[0].Id) {
          return 'ERROR:' + Label.Related_List_View_Name_Exists;
        }
      }
      delete [select Id 
              from User_List_View_Filter__c 
              where User_List_View__c = :userListView.Id];
  
      delete [select Id 
              from User_List_View_Column__c 
              where User_List_View__c = :userListView.Id];
  
      upsert userListView;
      for (User_List_View_Filter__c filter : filters) {
        filter.User_List_View__c = userListView.Id;
      }
      insert filters;
      for (User_List_View_Column__c column : columns) {
        column.User_List_View__c = userListView.Id;
      }
      insert columns;
      return 'SUCCESS:' + userListView.Id;
    }
  
    public class Relationship {
      @AuraEnabled
      public String childObjectLabel {get; set;}
      @AuraEnabled
      public String childObjectName {get; set;}
      @AuraEnabled
      public String lookupLabel {get; set;}
      @AuraEnabled
      public String lookupName {get; set;}
      
      public Relationship(String childObjectLabel, String childObjectName, 
        String lookupLabel, String lookupName) {
  
        this.childObjectLabel = childObjectLabel;
        this.childObjectName = childObjectName;
        this.lookupLabel = lookupLabel;
        this.lookupName = lookupName;
      }
    }
  
    public class ColumnsAndOperatorsWrapper {
      @AuraEnabled
      public Map<String, String> allColumnMap {get; set;}
      @AuraEnabled
      public Map<String, String> filterableColumnMap {get; set;}
      @AuraEnabled
      public Map<String, String> operatorMap {get; set;}
  
      public ColumnsAndOperatorsWrapper(Map<String, String> allColumnMap, 
        Map<String, String> filterableColumnMap, 
        Map<String, String> operatorMap) {
  
        this.allColumnMap = allColumnMap;
        this.filterableColumnMap = filterableColumnMap;
        this.operatorMap = operatorMap;
      }
    }
  
    public class RelatedListInfo {
      @AuraEnabled
      public Boolean shallShowFilterToggler {get; set;}
      @AuraEnabled
      public Boolean shallShowNewButton {get; set;}
      @AuraEnabled
      public String parentSObjectType {get; set;}
      @AuraEnabled
      public String relatedListLabel {get; set;}
      @AuraEnabled
      public String relationship {get; set;}
      @AuraEnabled
      public String sObjectPluralLabel {get; set;}
      @AuraEnabled
      public String sObjectType {get; set;}
  
      public RelatedListInfo(Boolean shallShowFilterToggler, 
        Boolean shallShowNewButton, String parentSObjectType, 
        String relatedListLabel, String relationship, 
        String sObjectPluralLabel, String sObjectType) {
  
        this.shallShowFilterToggler = shallShowFilterToggler;
        this.shallShowNewButton = shallShowNewButton;
        this.parentSObjectType = parentSObjectType;
        this.relatedListLabel = relatedListLabel;
        this.relationship = relationship;
        this.sObjectPluralLabel = sObjectPluralLabel;
        this.sObjectType = sObjectType;
      }
    }
  
    public class UserListViewAndDetailsWrapper {
      @AuraEnabled
      public String parentSObjectAPIName {get; set;}
      @AuraEnabled
      public User_List_View__c userListView {get; set;}
  
      public UserListViewAndDetailsWrapper(User_List_View__c userListView, 
        String parentSObjectAPIName) {
  
        this.userListView = userListView;
        this.parentSObjectAPIName = parentSObjectAPIName;
      }
    }
  }
  
public with sharing class OC_ProjectAuraController {


    public static FINAL String pQuery =
      'select ' +
        'Id, Name, OwnerId, Owner.Name, Developer__c, Developer__r.Name, ' +
        'Developer__r.Parent_Oculus_Account__c, ' +
        'Developer__r.Parent_Oculus_Account__r.Name, Content_Category__c, ' +
        'Content_Team__c, Funding_Amount_Roll_Up__c, Oculus_Platforms__c, ' +
        'Master_Project__c, Master_Project__r.Oculus_Platforms__c, ' +
        'Project_Phase__c, Project_Statuss__c, Oculus_Price__c, PrimaryTAM__c, ' +
        'PrimaryTAM__r.Name, Publisher__c, Publisher__r.Name, SecondaryTAM__c, ' +
        'SecondaryTAM__r.Name, User_Interaction_Modes__c, Ship_Date__c, ' +
        'Store_Section__c, TOTAL_Recoup_Amount__c, Project_Level__c, ' +
        'Supported_Player_Modes__c, Players__c, Other_Platforms__c, ' +
        'Controller_Support__c, principalDevContact__c, ' +
        'principalDevContact__r.Name, Principal_Publisher_Contact__c, ' +
        'Principal_Publisher_Contact__r.Name ' +
      'from Project__c ';
  
    public static FINAL String pCloneQuery =
      'select ' +
        'Actual_Q_Score__c, Add_to_Content_Release_Calendar__c, App_ID__c, ' +
        'Competitive_Analysis__c, Content_Category__c, ' +
        'Content_Sub_Category__c, Content_Type__c, Controller_Support__c, ' +
        'Developer__c, Dev_Price__c, Engineer__c, Experiences_Team_Project__c, ' +
        'Id, Launch_Region_Restrictions__c, Live_on_Store_before_GO_Launch__c, ' +
        'Localization__c, Major_IP__c, Master_Project__c, Use_Cases__c, ' +
        'Oculus_Platforms__c, Master_Project__r.Id, Project_Statuss__c, ' +
        'Master_Project__r.Oculus_Platforms__c, Oculus_Price__c, ' +
        'Other_Platforms__c, Platform_Features__c, Players__c, ' +
        'Predicted_Q_Score__c,Predicted__c, PrimaryTAM__c, ' +
        'principalDevContact__c, Principal_Publisher_Contact__c, Name, ' +
        'QA_Support__c, Rank__c, SecondaryTAM__c, Shipping_Engine__c, ' +
        'Social_Co_Presence__c, Store_App_Link__c, Store_Ops_Owner__c, ' +
        'Store_Section__c, Supported_Player_Modes__c, Task_Tag__c, ' +
        'Title_Description_for_Marketing__c, User_Interaction_Modes__c, ' +
        'X2d_Version__c, Ship_Date__c ' +
      'from Project__c';
  
    public static FINAL String mProjQuery =
      'select ' +
        'Id, Name, OwnerId, Owner.Name, Developer__c, Developer__r.Name, ' +
        'Developer__r.Parent_Oculus_Account__c, ' +
        'Developer__r.Parent_Oculus_Account__r.Name, ' +
        'Developer__r.OwnerId, Developer__r.Owner.Name, ' +
        'Content_Category__c, Genres__c, Content_Team__c, Oculus_Platforms__c, ' +
        'Publisher__c, Publisher__r.Name, PrimaryTAM__c, PrimaryTAM__r.Name, ' +
        'SecondaryTAM__c, SecondaryTAM__r.Name, Supported_Player_Modes__c, ' +
        'User_Interaction_Modes__c, Funding_Amount_Roll_Up__c, ' +
        'Recoupable_Amount_Roll_Up__c ' +
      'from Master_Project__c ';
  
    //Method to delete Project
    @AuraEnabled
    public static ProjectAuraCntrResponse deleteProject(Project__c proj) {
      if (Schema.sObjectType.Project__c.isAccessible()
        && Schema.sObjectType.Project__c.isDeletable()) {
  
        try {
          String mProjId = proj.Master_Project__c;
          delete proj;
          return new ProjectAuraCntrResponse('SUCCESS',
            'Project has been deleted successfully.');
  
        } catch (Exception ex) {
          return new ProjectAuraCntrResponse('ERROR', ex.getMessage());
        }
      } else {
        return new ProjectAuraCntrResponse('ERROR',
          'You do not have permissions to delete this record.');
      }
    }
  
    //Method to delete all Projects of a Master Project
    @AuraEnabled
    public static ProjectAuraCntrResponse deleteMasterProject(
      Master_Project__c mProj) {
  
      if (Schema.sObjectType.Project__c.isAccessible()
          && Schema.sObjectType.Project__c.isDeletable()) {
  
        try {
          delete [select Id
                  from Project__c
                  where Master_Project__c = :mProj.Id];
  
          return new ProjectAuraCntrResponse('SUCCESS',
            'Project has been deleted successfully.');
  
        } catch(Exception ex) {
          return new ProjectAuraCntrResponse('ERROR', ex.getMessage());
        }
      } else {
        return new ProjectAuraCntrResponse('ERROR',
          'You do not have permissions to delete this record.');
      }
    }
  
    @AuraEnabled
    public static String[] getRecordsBeingUpdated(Project__c proj,
      String platformsToBeCloned) {
  
      String[] copyPlatformList = platformsToBeCloned.split(';');
      //Getting the list of project which needs to be updated
      List<Project__c> projList =
        [select Id, Name
         from Project__c
         where Master_Project__c =: proj.Master_Project__c
         and (Project_Statuss__c not in ('Launched') or Id = :proj.Id)
         and (Oculus_Platforms__c = :copyPlatformList or Id = :proj.Id)];
  
      String[] projNameSet = new List<String> ();
      for (Project__c prj : projList) {
        projNameSet.add(prj.Name);
      }
  
      return projNameSet;
    }
  
    @AuraEnabled
    public static void replicateUpdatedProjectFields (Project__c proj,
      String copyPlatformStr, Boolean statusChanged) {
  
      String[] copyPlatformList = copyPlatformStr.split(';');
  
      //Getting the list of project which needs to be updated
      List<Project__c> projList =
        [select Id, Updated_Field_List__c,
                Project_Statuss__c, Oculus_Platforms__c
         from Project__c
         where Master_Project__c = :proj.Master_Project__c
         and (Project_Statuss__c not in ('Launched') or Id = :proj.Id)
         and (Oculus_Platforms__c = :copyPlatformList or Id = :proj.Id)];
  
      String updatedFieldStr = '';
      for (Project__c prj : projList) {
        if (prj.Id == proj.Id && prj.Updated_Field_List__c != null)
          updatedFieldStr = prj.Updated_Field_List__c;
      }
      String[] updatedFieldList;
      if (updatedFieldStr.length() > 1) {
        updatedFieldList = updatedFieldStr.split(';');
      } else {
        updatedFieldList = new List<String> ();
      }
  
      if (statusChanged) {
        updatedFieldList.add('Project_Statuss__c');
      }
  
      if (updatedFieldList.size() > 0) {
        String projId = proj.Id;
        String query = 'select Id, ';
        for (Integer i = 0; i < updatedFieldList.size(); i++) {
          if (String.isNotBlank(updatedFieldList[i])) {
            query += updatedFieldList[i] + ',';
          }
        }
        query += 'Name from Project__c ';
        query += 'where Id = :projId ';
  
        List<sObject> sobjList = Database.query(query);
  
        Sobject sObj = sobjList.get(0);
  
        List<Project__c> projToBeUpdated = new List<Project__c> ();
        for (Project__c prj : projList) {
          if (prj.Id != proj.Id) {
            for (Integer i = 0; i < updatedFieldList.size(); i++) {
              prj.put(updatedFieldList[i], sObj.get(updatedFieldList[i]));
            }
          }
          prj.put('Updated_Field_List__c', NULL);
          projToBeUpdated.add(prj);
        }
        update projToBeUpdated;
      }
    }
  
    @AuraEnabled
    public static Project__c updateProject (Project__c proj) {
      update proj;
  
      return [select Id, Name, Master_Project__c,
                     Oculus_Platforms__c, Project_Statuss__c
              from Project__c
              where Id = :proj.Id];
    }
  
    @AuraEnabled
    public static Project__c updateProjectStatus (Project__c proj,
      String priorStatus) {
  
      OC_ProjectUtils.setRecordType(new List<Project__c>{proj});
      proj.Project_Statuss__c = priorStatus;
      update proj;
  
      return [select Id, Name, Master_Project__c,
                     Oculus_Platforms__c, Project_Statuss__c
              from Project__c
              where Id = :proj.Id];
    }
  
    @AuraEnabled
    public static Project__c revertProjectStatus (Project__c proj) {
      OC_ProjectUtils.setRecordType(new List<Project__c>{ proj });
      update proj;
  
      return [select Id, Name, Master_Project__c,
                     Oculus_Platforms__c, Project_Statuss__c
              from Project__c
              where Id = :proj.Id];
    }
  
    //TODO: Merge with saveProject method
    @AuraEnabled
    public static Project__c saveProjectVideoOnly (Project__c proj,
        Master_Project__c masterProj, String ocPlts) {
  
      insert masterProj;
  
      List<Project__c> projList = new List<Project__c> ();
      for (String ocPlatform : ocPlts.split(';')) {
        Project__c cProj = proj.clone(false, false, false, false);
  
        cProj.Name = proj.Name + ' (' + ocPlatform.trim() + ')';
        cProj.Master_Project__c = masterProj.Id;
        cProj.Oculus_Platforms__c = ocPlatform;
  
        projList.add(cProj);
      }
      insert projList;
  
      return projList[0];
    }
  
    @AuraEnabled
    public static Project__c saveProject (Project__c proj,
      Master_Project__c masterProj, Boolean isDemo) {
  
      System.debug('>>>>>proj:::'+proj);
      System.debug('>>>>>proj:::'+masterProj);
      Boolean isMedia = false;
      if(proj.Content_Category__c  == 'Media'){
        isMedia = true;
      }
      if(isMedia) {
          System.debug('----Line 226----');
        proj.Oculus_Platforms__c = '';
        masterProj.Oculus_Platforms__c = '';
      }
      insert masterProj;
  
      List<Project__c> projList = new List<Project__c> ();
      if(! isMedia){
        for (String ocPlatform : proj.Oculus_Platforms__c.split(';')) {
          Project__c cProj = proj.clone(false, true, false, false);
  
          cProj.Name = isMedia ? proj.Name : proj.Name + ' (' + ocPlatform.trim() + ')';
          cProj.Master_Project__c = masterProj.Id;
          cProj.Project_Level__c = 'Platform';
          cProj.Oculus_Platforms__c = ocPlatform;
  
          projList.add(cProj);
  
          if (isDemo) {
            Project__c dProj = proj.clone(false, true, false, false);
  
            dProj.Name = proj.Name + ': Demo (' + ocPlatform.trim() + ')';
            dProj.Master_Project__c = masterProj.Id;
            dProj.Project_Level__c = 'Demo';
            dProj.Oculus_Platforms__c = ocPlatform;
  
            projList.add(dProj);
          }
        }
      }else{
        proj.Master_Project__c = masterProj.Id;
        projList.add(proj);
      }
      insert projList;
  
      return projList.get(0);
    }
  
    @AuraEnabled
    public static void updatePlatformOnMasterProject (Project__c proj,
      String platform) {
  
      Master_Project__c mProj = new Master_Project__c();
      mProj.Id = proj.Master_Project__r.id;
      mProj.Oculus_Platforms__c =
        proj.Master_Project__r.Oculus_Platforms__c + ';' + platform;
  
      update mProj;
    }
  
    @AuraEnabled
    public static Project__c cloneProject (String projId, String level,
      String cloneProjectName, String activeDemoPlatforms, String projectStatus,
      Date shipDate, String shipDateConfidence) {
  
        System.debug('>>>>>projId:::'+projId);
        System.debug('>>>>>level:::'+level);
        System.debug('>>>>>cloneProjectName:::'+cloneProjectName);
        System.debug('>>>>>activeDemoPlatforms:::'+activeDemoPlatforms);
        System.debug('>>>>>projectStatus:::'+projectStatus);
        System.debug('>>>>>shipDate:::'+shipDate);
        System.debug('>>>>>shipDateConfidence:::'+shipDateConfidence);
  
      List<Project__c> projListToInsert = new List<Project__c> ();
  
      Project__c proj = getProjectToBeCloned(projId, level);
      String activePlatforms = proj.Master_Project__r.Oculus_Platforms__c;
  
      Project__c cProj = proj.clone(false, true, false, false);
      cProj.Cloned_Project_Id__c = proj.Id;
      cProj.Ship_Date__c = null;
      cProj.Project_Level__c = level;
      cProj.Project_Statuss__c = projectStatus;
  
      if (shipDate != null) {
        cProj.Ship_Date__c = shipDate;
        cProj.Ship_Date_Confidence__c = shipDateConfidence;
      }
  
      if (level == 'Platform' || level == 'Video Only') {
        List<String> clonePlatformArr;
        if (cloneProjectName.contains(',')) {
          clonePlatformArr = cloneProjectName.split(',');
        } else {
          clonePlatformArr = new List<String> ();
          clonePlatformArr.add(cloneProjectName);
        }
        for (String str : clonePlatformArr) {
          Project__c nProj =
            OC_ProjectAuraHelper.getClonedProject(cProj, null, str, level);
  
          nProj.Actual_Q_Score__c = null;
          nProj.Predicted_Q_Score__c = null;
          nProj.Predicted__c = null;
          if (level == 'Platform') {
            nProj.App_ID__c = null;
            nProj.Add_to_Content_Release_Calendar__c = true;
          }
          projListToInsert.add(nProj);
        }
        cloneProjectName = cloneProjectName.replace(',', ';');
        updatePlatformOnMasterProject(proj, cloneProjectName);
  
      } else if (level == 'Demo') {
        List<String> clonePlatformArr;
        System.debug('----Line 349, clonePlatformArr---' +clonePlatformArr);
        if (cloneProjectName.contains(',')) {
          System.debug('----Line 351----');
          clonePlatformArr = cloneProjectName.split(',');
        } else {
          System.debug('----Line 354---');
          clonePlatformArr = new List<String> ();
          clonePlatformArr.add(cloneProjectName);
          System.debug('----Line 357, clonePlatformArr---' +clonePlatformArr);
        }
  
        for (String str : clonePlatformArr) {
          Project__c dProj =
            OC_ProjectAuraHelper.getClonedProject(cProj, level, str, level);
  
          System.debug('----Line 364, for loop---');
          dProj.Actual_Q_Score__c = null;
          dProj.Predicted_Q_Score__c = null;
          dProj.Predicted__c = null;
          projListToInsert.add(dProj);
  
          if (activeDemoPlatforms.contains(str)) {
            continue;
          } else {
            Project__c nProj =
              OC_ProjectAuraHelper.getClonedProject(cProj, level,
                str, 'Platform');
  
  
            System.debug('----Line 378---');
            nProj.Actual_Q_Score__c = null;
            nProj.Predicted_Q_Score__c = null;
            nProj.Predicted__c = null;
            projListToInsert.add(nProj);
          }
        }
        cloneProjectName = cloneProjectName.replace(',', ';');
        System.debug('----Line 386,cloneProjectName ---' +cloneProjectName);
        updatePlatformOnMasterProject(proj, cloneProjectName);
  
      } else if (level == 'Content Update' || level == 'Episode' ||
        level == 'Coming Soon' || level == 'DLC' || level == 'Pre-Orders') {
  
        if (level != 'Episode') {
          cProj.QA_Support__c = null;
          if (level == 'Coming Soon' || level == 'Pre-Orders') {
            cProj.Add_to_Content_Release_Calendar__c = false;
          } else if (level == 'Content Update' || level == 'DLC') {
            cProj.Add_to_Content_Release_Calendar__c = true;
            if (level == 'Content Update') {
              cProj.Oculus_Price__c = null;
            }
          }
        }
        cProj.Name =
          OC_ProjectAuraHelper.getProjectName(proj.Name, cloneProjectName,
          proj.Oculus_Platforms__c, level);
        projListToInsert.add(cProj);
      }
      System.debug('----Line 408---');
      insert projListToInsert;
      System.debug('----Line 410---');
      return projListToInsert[0];
    }
  
    @AuraEnabled
    public static Project__c cloneBetaProject(String projId, String level,
      String cloneProjectName, Date startDate, Date endDate,
      Date buildDueDate, String notes) {
  
  
        System.debug('>>>>>projId:::'+projId);
        System.debug('>>>>>level:::'+level);
        System.debug('>>>>>cloneProjectName:::'+cloneProjectName);
        System.debug('>>>>>startDate:::'+startDate);
        System.debug('>>>>>endDate:::'+endDate);
        System.debug('>>>>>buildDueDate:::'+buildDueDate);
        System.debug('>>>>>notes:::'+notes);
  
      Project__c proj = getProjectToBeCloned(projId, level);
  
  
      System.debug('>>>>>proj:::'+proj);
  
      Project__c cProj = proj.clone(false, true, false, false);
      cProj.Cloned_Project_Id__c = proj.Id;
      cProj.Project_Level__c = level;
  
      if (proj.Name.indexOf(':') > 0) {
        System.debug('>>>>>Line 438----');
        cProj.Name = proj.Name.substring(0, proj.Name.indexOf(':')) + ': '
          + cloneProjectName + ' (' + proj.Oculus_Platforms__c + ')';
      } else if (proj.Name.indexOf(' (') > 0) {
        System.debug('>>>>>Line 442----');
        cProj.Name = proj.Name.substring(0, proj.Name.indexOf(' (')) + ': '
          + cloneProjectName + ' (' + proj.Oculus_Platforms__c + ')';
      } else {
        System.debug('>>>>>Line 446----');
        cProj.Name = proj.Name + ': '
          + cloneProjectName + ' (' + proj.Oculus_Platforms__c + ')';
      }
  
      cProj.Open_Close_Beta_Start_Date__c = Date.valueOf(startDate);
      System.debug('>>>>>Line 452----');
      cProj.Open_Close_Beta_End_Date__c = Date.valueOf(endDate);
      System.debug('>>>>>Line 454----');
      if (buildDueDate != null) {
        cProj.Open_Close_Beta_Build_Due_Date__c = Date.valueOf(buildDueDate);
      }
      cProj.Open_Close_Beta_Notes__c = notes;
      cProj.Actual_Q_Score__c = null;
      cProj.Predicted_Q_Score__c = null;
      cProj.Predicted__c = null;
  
      insert cProj;
  
      System.debug('>>>>>Line cProj----' +cProj);
  
      return cProj;
    }
  
    public static Project__c getProjectToBeCloned(String projId, String level) {
      String query = pCloneQuery + ' where Id = :projId';
      return Database.query(query);
    }
  
    @AuraEnabled
    public static Map<String, List<Object>> getSelectedProjectList(
      String sRecordId) {
  
      Map < String, List<Object> > projectChildrenMap =
        new Map < String, List<Object> >();
  
      List<Object> sObjList = new List<Object> ();
      String query = pQuery + 'where Id = :sRecordId';
      Project__c selProj = Database.query(query);
  
      String masterProjId = selProj.Master_Project__c;
      String mpQuery = mProjQuery;
      query = mpQuery + 'where Id = :masterProjId  ';
      List<Master_Project__c> masterProject = Database.query(query);
  
      //getting total funding amount based on sharing rules access
      //since class is with sharing, below query will pull only the records
      //which user has access to
      AggregateResult[] grpdRlts = [select SUM(Amount__c) fundAmnt
                                    from Funding__c
                                    where Master_Project__c = :masterProjId
                                    and Funding_Type__c = 'Development'];
  
      Double fundAmnt = Double.valueOf(grpdRlts[0].get('fundAmnt'));
      masterProject.get(0).Funding_Amount_Roll_Up__c = fundAmnt;
  
      List<Project__c> mProjChildrenList =
        getMasterProjectChildren(masterProjId);
  
      if (mProjChildrenList.size() > 0) {
        projectChildrenMap =
          OC_ProjectAuraHelper.getMasterProjectChildrenMap(masterProjId,
            mProjChildrenList);
  
        sObjList.add(selProj);
        sObjList.add(masterProject.get(0));
        sObjList.add(
          OC_ProjectAuraHelper.getLiveProjectPlatforms(mProjChildrenList));
  
        projectChildrenMap.put('ProjList', sObjList);
      }
      return projectChildrenMap;
    }
  
    @AuraEnabled
    public static List<Project__c> getMasterProjectChildren(String recordId) {
  
      String query = pQuery +
        'where Master_Project__c = :recordId ' +
        'order by Ship_Date__c desc NULLS FIRST, Name desc, CreatedDate desc';
  
      List<Project__c> projList = Database.query(query);
      return projList;
    }
  
    @AuraEnabled
    public static List<Project_Console_Summary_Field_List__mdt>
      getProjectConsoleUIFieldList() {
  
      return [select MasterLabel, QualifiedApiName, Field_API__c,
                     Ref_Field_API__c, Field_Name__c, Is_Calculated_Field__c,
                     Is_Reference_Field__c, Order__c, Section_Name__c
              from Project_Console_Summary_Field_List__mdt
              order by Section_Name__c desc, Order__c asc];
    }
  
    @AuraEnabled
    public static List<String> getProjectContentCategory () {
      return OC_ProjectAuraUtil.getProjectContentCategory(true);
    }
  
    @AuraEnabled
    public static List<String> getProjectOculusPlatform () {
      return OC_ProjectAuraUtil.getProjectOculusPlatform(false);
    }
  
    @AuraEnabled
    public static List<String> getProjectStatus () {
      return OC_ProjectAuraUtil.getProjectStatus(false);
    }
  
    @AuraEnabled
    public static List<String> getProjectPhase () {
      return OC_ProjectAuraUtil.getProjectPhase(false);
    }
  
    @AuraEnabled
    public static List<String> getProjectShipDateConfidence () {
      return OC_ProjectAuraUtil.getProjectShipDateConfidence(true);
    }
  
    @AuraEnabled
    public static String getUserContentTeam() {
      OC_AuraControllerUtil.UserInfoWrapper uWrp =
        OC_AuraControllerUtil.getUserDetails(UserInfo.getUserId());
  
      return uWrp.ContentTeam;
    }
  
    @AuraEnabled
    public static String getUserProfileName () {
      OC_AuraControllerUtil.UserInfoWrapper uWrp =
        OC_AuraControllerUtil.getUserDetails(UserInfo.getUserId());
  
      return uWrp.ProfileName;
    }
  
    public class ProjectWrapper {
      @AuraEnabled
      public String fieldLabel {get;set;}
      @AuraEnabled
      public String fieldAPI {get;set;}
      @AuraEnabled
      public String fieldValue {get;set;}
      @AuraEnabled
      public String fieldRefId {get;set;}
      @AuraEnabled
      public Boolean isLink {get;set;}
      @AuraEnabled
      public Integer order {get;set;}
  
    }
  
    public class ProjectAuraCntrResponse {
      public ProjectAuraCntrResponse() {
      }
      public ProjectAuraCntrResponse (String respCode, String respMsg) {
        this.RESPONSE_CODE = respCode;
        this.RESPONSE_MSG = respMsg;
      }
      @AuraEnabled
      public String RESPONSE_CODE {get;set;}
      @AuraEnabled
      public String RESPONSE_MSG {get;set;}
    }
  }
  
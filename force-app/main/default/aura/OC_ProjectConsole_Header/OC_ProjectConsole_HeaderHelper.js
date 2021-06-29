({
    getProjectList : function(component) {
      var self = this;
      var sRecordId = component.get("v.sRecordId");
  
      var sProjectList = [];
      var action = component.get("c.getSelectedProjectList");
      action.setParam("sRecordId", sRecordId);
      action.setCallback(this, function(response) {
        var state = response.getState();
        if(state === "SUCCESS") {
          var responseMap = response.getReturnValue();
          sProjectList = responseMap['ProjList'];
          delete responseMap['ProjList'];
  
          component.set("v.sRecordId", sProjectList[0].Id);
          component.set("v.sProject", sProjectList[0]);
  
          var uProject = sProjectList[1];
          var livePlatforms = sProjectList[2];
          uProject.Live_Platforms__c = livePlatforms;
          component.set("v.uRecordId", sProjectList[1].Id);
          component.set("v.uProject", sProjectList[1]);
  
          if(sProjectList[1] != undefined && sProjectList[1] != null &&
              sProjectList[1].Content_Category__c != 'Media')  {
  
            var activePlatforms = sProjectList[1].Oculus_Platforms__c;
            var activePlatformsList = activePlatforms.split(";");
  
            component.set("v.activePlatformsList", activePlatformsList);
          }
  
          var activeTab ;
          if(sProjectList[0].Project__c == sProjectList[1].Id) {
            activeTab = 'L1_'+sProjectList[0].Id;
          } else {
            activeTab = 'L2_'+sProjectList[0].Id;
          }
  
          self.getProjectWrapper(component);
  
          sRecordId = component.get("v.sRecordId");
          var recordId = component.get("v.recordId");
  
          console.log(recordId + ' --- ' + sRecordId);
  
          component.set("v.projectChildMap", responseMap);
  
          var consoleEvent = $A.get("e.c:OC_ProjectConsoleEvent");
          consoleEvent.setParams({
            "projectChildMap" : component.get("v.projectChildMap"),
            "sRecordId" : component.get("v.sRecordId"),
            "sRecord" : component.get("v.sProject"),
            "uRecordId" : component.get("v.uRecordId"),
            "uRecord" : component.get("v.uProject"),
            "activeTab" : activeTab,
            "hSummarySectionFieldsList" : component.get("v.hSummarySectionFieldsList"),
            "headerSObjectWrapper" : component.get("v.sObjectWrapper"),
            "isRedirect" : true
          });
          console.log("****** CALLING OC_ProjectConsoleEvent FROM HEADER ******");
          consoleEvent.fire();
  
        } else {
          component.set("v.sRecordId", null);
          component.set("v.sProject", null);
          component.set("v.uRecordId", null);
          component.set("v.uProject", null);
        }
  
      });
      $A.enqueueAction(action);
  
    },
    getProjectWrapper : function(component) {
  
      var self = this;
      var uProj = component.get("v.uProject");
      var hsfLst = component.get("v.hSummarySectionFieldsList")
  
      var projWrpList = [];
      var projWrp ;
      for(var i = 0; i < hsfLst.length; i++) {
        var hsf = hsfLst[i];
        if(hsf.Section_Name__c == 'Child Summary') {
          continue;
        }
  
        projWrp = new Object ();
        projWrp.fieldLabel = hsf.Field_Name__c;
        projWrp.fieldAPI = hsf.Field_API__c;
        projWrp.fieldValue = self.getFieldValue(uProj, hsf.Field_API__c);
        //console.log("Is_Reference_Field__c :: "+hsf.Is_Reference_Field__c);
        if(hsf.Is_Reference_Field__c) {
          //console.log("Is_Reference_Field__c YES :: "+self.getFieldValue(uProj, hsf.Ref_Field_API__c));
          projWrp.fieldRefId = self.getFieldValue(uProj, hsf.Ref_Field_API__c);
        }
        projWrp.isLink = hsf.Is_Reference_Field__c;
  
        projWrpList.push(projWrp);
      }
      //console.log("projWrpList :: " + JSON.stringify(projWrpList) );
  
      component.set("v.sObjectWrapper", projWrpList);
    },
    getFieldValue : function(record, fieldApi) {
      //console.log("1 : "+fieldApi);
      if(fieldApi.includes(".")) {
        if((fieldApi.match( RegExp('\\.','g') ) || [] ).length == 2) {
          var sStr = fieldApi.split(".");
          return (record[sStr[0]] && record[sStr[0]][sStr[1]] && record[sStr[0]][sStr[1]][sStr[2]]) ? record[sStr[0]][sStr[1]][sStr[2]] : null;
        } else if((fieldApi.match( RegExp('\\.','g') ) || []).length == 1) {
          var sStr = fieldApi.split(".");
          return (record[sStr[0]] && record[sStr[0]][sStr[1]]) ? record[sStr[0]][sStr[1]] : null;
        }
      } else {
        return record[fieldApi];
      }
    },
    newFeaturingRequestModal : function(cmp, modalComponentName, modalProperties) {
      $A.createComponent(
          modalComponentName,
          modalProperties,
          function(newModal, status, errorMessage) {
            if (status === "SUCCESS")
              cmp.set("v.modal", newModal);
            else if (status === "INCOMPLETE")
              console.log("No response from server or client is offline.")
              else if (status === "ERROR")
                console.log("Error: " + errorMessage);
          }
      );
    },
    createEditProjectModal : function(component, event, isBulk) {
      var sRecordId = component.get("v.sRecordId");
      console.log("Inside createEditProjectModal : sRecordId :: "+ sRecordId);
  
      var sRecord = component.get("v.sProject");
      console.log("Inside createEditProjectModal : sRecord :: "+ JSON.stringify(sRecord) );
  
      var sObjectRecordPlatform = sRecord.Oculus_Platforms__c;
      console.log("Inside createEditProjectModal : sObjectRecordPlatform :: "+ sObjectRecordPlatform);
  
      var activePlatformsList = component.get("v.activePlatformsList");
      if(!isBulk) {
        activePlatformsList = null;
      }
      console.log("Inside createEditProjectModal : activePlatformsList :: "+ activePlatformsList);
  
      $A.createComponent(
          "c:OC_ProjectConsole_Edit",
          {
            "sObjectRecord":sRecord,
            "sObjectRecordId":sRecordId,
            "sObjectRecordPlatform":sObjectRecordPlatform,
            "activePlatformsList":activePlatformsList
          },
          function(newModal, status, errorMessage) {
            if (status === "SUCCESS")
              component.set("v.modal", newModal);
            else if (status === "INCOMPLETE")
              console.log("No response from server or client is offline.")
              else if (status === "ERROR")
                console.log("Error: " + errorMessage);
          }
      );
  
    },
    displayToastMessage : function (cmp, evt, mode, isSuccess, msg) {
      var title = 'Failed';
      var type = 'error';
      if(isSuccess) {
        title = 'Saved';
        type = 'success';
      }
      // record is saved successfully
      var resultsToast = $A.get("e.force:showToast");
      resultsToast.setParams({
        "title": title,
        "type": type,
        "message": msg,
        "mode": mode
      });
      // Update the UI: close panel, show toast
      $A.get("e.force:closeQuickAction").fire();
      resultsToast.fire();
    }
  
  })
  
({
    doInit: function(component, event, helper) {
      var sRecordId;
      if (component.get("v.recordId")) {
        sRecordId = component.get("v.recordId");
        component.set("v.sRecordId", sRecordId);
      }
  
      var action = component.get("c.getUserProfileName");
      action.setStorable();
      action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var profileName = response.getReturnValue();
          if (profileName == 'System Administrator' ||
            profileName == 'Exec & Ops' ||
            profileName == 'Oculus System Administrator - Limited') {
  
            component.set("v.enableDelete", true);
          }
        } else{
          component.set("v.enableDelete", false);
        }
      });
      $A.enqueueAction(action);
  
      var hSmrySecFldsLst = [];
      var action = component.get("c.getProjectConsoleUIFieldList");
      action.setStorable();
      action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var fieldList = response.getReturnValue();
          hSmrySecFldsLst = [] ;
          for(var i = 0; i < fieldList.length; i++) {
            hSmrySecFldsLst.push(fieldList[i]);
          }
          component.set("v.hSummarySectionFieldsList", hSmrySecFldsLst);
          helper.getProjectList(component);
        } else{
          component.set("v.hSummarySectionFieldsList", null);
        }
      });
      $A.enqueueAction(action);
    },
    handleEdit: function(component, event, helper) {
      helper.createEditProjectModal(component, event, false);
    },
    handleBulkEdit: function(component, event, helper) {
      helper.createEditProjectModal(component, event, true);
    },
    handleDelete: function(component, event, helper) {
      var sProj = component.get("v.sProject");
      var r = confirm("Do you want you want to delete '"+sProj.Name+"' Project?");
      if (r == true) {
        var action = component.get("c.deleteProject");
        action.setParam( "proj", sProj );
        action.setCallback(this, function(response) {
          var state = response.getState();
          var resp = response.getReturnValue();
          if (state === "SUCCESS") {
            if (resp.RESPONSE_CODE == 'SUCCESS') {
              helper.displayToastMessage(component, event, 'dismissible', true, resp.RESPONSE_MSG);
              var projHomeEvent = $A.get("e.force:navigateToObjectHome");
              projHomeEvent.setParams({
                "scope": "Project__c"
              });
              projHomeEvent.fire();
            } else {
              helper.displayToastMessage(component, event, 'sticky', false, resp.RESPONSE_MSG);
            }
          } else {
            helper.displayToastMessage(component, event, 'sticky', false, "There was an exception while deleting the Project. Please contact System Administrator.");
          }
        });
        $A.enqueueAction(action);
      }
    },
    handleDeleteMasterProject: function(component, event, helper) {
      var mProj = component.get("v.uProject");
      var r = confirm("Do you want you want to delete '"+mProj.Name+"' Master Project and its child Projects? ");
      if (r == true) {
        var action = component.get("c.deleteMasterProject");
        action.setParam( "mProj", mProj );
        action.setCallback(this, function(response) {
          var state = response.getState();
          var resp = response.getReturnValue();
          if (state === "SUCCESS") {
            if (resp.RESPONSE_CODE == 'SUCCESS') {
              helper.displayToastMessage(component, event, 'dismissible', true, resp.RESPONSE_MSG);
              var projHomeEvent = $A.get("e.force:navigateToObjectHome");
              projHomeEvent.setParams({
                "scope": "Project__c"
              });
              projHomeEvent.fire();
            } else {
              helper.displayToastMessage(component, event, 'sticky', false, resp.RESPONSE_MSG);
            }
          } else {
            helper.displayToastMessage(component, event, 'sticky', false, "There was an exception while deleting the Project. Please contact System Administrator.");
          }
        });
        $A.enqueueAction(action);
      }
    },
    handleNewFeaturingRequest: function(component, event, helper) {
      helper.newFeaturingRequestModal(
          component, "c:OC_CreateFeaturingRequest",
          {
            'sObjectName':'Store_Featuring_Request__c',
            'selectedProject':component.get("v.sProject")
          }
      );
    },
    handleProjectDetailConsoleEvent: function(component, event, helper) {
      component.set("v.sRecordId", event.getParam("sRecordId"));
      component.set("v.sProject", event.getParam("sRecord"));
    },
    reloadPage: function(component, event, helper) {
      $A.get('e.force:refreshView').fire();
    },
    handleNewHardwareRequest : function(component) {
      var projId = component.get("v.sProject").Id;
      var accId = component.get("v.sProject").Developer__c;
      var urlEvent = $A.get("e.force:navigateToURL");
      urlEvent.setParams({
        "isredirect" : true,
        "url": "/apex/OC_HardwareRequestNewProjectDetail?Id=" + projId +
          "&accId=" + accId
      });
      urlEvent.fire();
    },
    handleAddProject : function(component) {
      component.set("v.addProject", true);
      var projectSummaryList = component.get("v.sObjectWrapper");
      var contentCategory = '';
      for(let i = 0; i < projectSummaryList.length; i++){
        if(projectSummaryList[i].fieldAPI == 'Content_Category__c'){
          contentCategory = projectSummaryList[i].fieldValue;
        }
      }
      component.set("v.contentCategory", contentCategory);
      var sRecordId = component.get("v.recordId");
      component.set("v.sRecordId", sRecordId);
      var sRecord = component.get("v.sProject");
      var projectPlatform = sRecord.Oculus_Platforms__c;
      component.set("v.projectPlatform", projectPlatform);
    }
  
  })
  
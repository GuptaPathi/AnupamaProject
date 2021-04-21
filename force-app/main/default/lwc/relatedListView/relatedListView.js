import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import getRelatedListInfo from '@salesforce/apex/RelatedListViewController.getRelatedListInfo';

export default class RelatedListView extends NavigationMixin(LightningElement) {
  @api listViewConfigId;
  @api recordId;
  @api relatedListIcon;
  @api relatedListLabel;
  @api useParentFilterOnly = false;
  @track parentSObjectType;
  @track recordsDisplayed = 0;
  @track shallRenderUserListViewData = false;
  @track shallShowFilterToggler = false;
  @track shallShowNewButton = false;
  @track sObjectType;
  @track recordName = '';
  @track totalRecordCount = 0;
  iconClicked = false;
  refresh = 'refresh';
  relationship;
  sObjectPluralLabel = '';
  standAloneComponent = false;

  @wire (CurrentPageReference) currentPageReference;

  @wire (getRelatedListInfo, {
    userListViewId: '$listViewConfigId'
  }) fetchULVDetails(result) {
    if (result.data) {
      this.parentSObjectType = result.data.parentSObjectType;
      this.relationship = result.data.relationship;
      this.sObjectType = result.data.sObjectType;
      this.sObjectPluralLabel = result.data.sObjectPluralLabel;
      this.shallShowFilterToggler = result.data.shallShowFilterToggler;
      this.shallShowNewButton = result.data.shallShowNewButton;
      this.shallRenderUserListViewData = true;
      if (!this.relatedListIcon) {
        this.relatedListIcon = 'standard:default';
      }
      if (!this.relatedListLabel) {
        this.relatedListLabel = result.data.relatedListLabel;
      }
    } else if (result.error) {
      console.log(result.error);
    }
  }

  get activeLabel() {
    return 'Show filtered ' + this.sObjectPluralLabel;
  }

  get inactiveLabel() {
    return 'Show all ' + this.sObjectPluralLabel;
  }

  get isInPageLayout() {
    return this.currentPageReference === null || 
      this.currentPageReference.state === null || 
      this.currentPageReference.state.c__recordId === undefined;
  }

  get shallShowMoreLink() {
    return this.totalRecordCount > 0 && this.totalRecordCount > this.recordsDisplayed;
  }

  onFilterToggled(event) {
    this.template.querySelector('c-list-view').showSpinner();
    this.useParentFilterOnly = event.target.checked;
  }

  onIconClicked() {
    if (this.currentPageReference != null && this.currentPageReference.state != null && 
      this.currentPageReference.state.c__admin == 'true') {
     
      if (!this.iconClicked) {
        this.iconClicked = true;
      } else {
        this.iconClicked = false;
        this[NavigationMixin.GenerateUrl]({
          type: 'standard__recordPage',
          attributes: {
            recordId: this.listViewConfigId,
            objectApiName: 'User_List_View__c',
            actionName: 'view'
          }
        }).then(url => {
          window.open(url);
        });
      }
    }
  }

  onNewClicked() {
    this[NavigationMixin.Navigate]({
      type: 'standard__objectPage',
      attributes: {
        objectApiName: this.sObjectType,
        actionName: 'new'
      },
      state : {
        defaultFieldValues: this.relationship + "=" + this.recordId
      }
    });
  }

  navigateToId() {
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: this.recordId,
        objectApiName: 'undefined',
        actionName: 'view'
      }
    });
  }

  navigateToRecordTypeHome() {
    this[NavigationMixin.Navigate]({
      type: 'standard__objectPage',
      attributes: {
        objectApiName: this.parentSObjectType,
        actionName: 'home'
      }
    });
  }

  recordLoaded(event) {
    this.recordName = event.detail.records[this.recordId].fields.Name.value;
  }

  viewMore() {
    this[NavigationMixin.Navigate]({
      type: 'standard__component',
      attributes: {
        componentName: 'c__relatedListViewContainer'
      },
      state: {
        c__listViewConfigId: this.listViewConfigId,
        c__recordId: this.recordId,
        c__relatedListIcon: this.relatedListIcon,
        c__relatedListLabel: this.relatedListLabel,
        c__useParentFilterOnly: this.useParentFilterOnly
      }
    });
  }

  totalrecordsreceived(event) {
    this.totalRecordCount = event.detail.totalreocrds;
    this.recordsDisplayed = event.detail.recordsDisplayed;
  }
}

import { Controller } from 'stimulus';
import { EVENT_LIST, attach, detach} from '../utils/events';

export default class extends Controller {
  static targets = [
    'mandatoryField',
    'disabledField',
    'coordinatesAreFilled'
  ];

  static values = {
    minimumLength: Number,
    noEventCheck: Boolean
  }

  fieldChange(event){
    this.checkValidation();
  }

  coordinatesChanged(event){
    this.coordinatesAreFilled = this.noEventCheckValue || (event.detail.latitude !== 0 && event.detail.longitude !== 0);
    this.checkValidation();
  }

  areAllMandatoryFieldsFilled(){
    let allMandatoryFieldsAreFilled = true;
    this.mandatoryFieldTargets.forEach((field) => {
      if (field.value.length <= this.minimumLengthValue) {
        allMandatoryFieldsAreFilled = false;
      }
    });

    allMandatoryFieldsAreFilled &&= this.coordinatesAreFilled;

    return allMandatoryFieldsAreFilled
  }

  // possible values are 'disabled' or 'enabled'
  setDisabledFieldsTo(status){
    const disabledFields = this.disabledFieldTargets;
    disabledFields.forEach((field) => {
      field.disabled =  (status === 'disabled') ;
    });
  }

  checkValidation(){
    if(this.areAllMandatoryFieldsFilled()){
      this.setDisabledFieldsTo('enabled');
    } else {
      this.setDisabledFieldsTo('disabled');
    }
  }

  connect(){
    attach(EVENT_LIST.COORDINATES_CHANGED,this.coordinatesChanged.bind(this));
    this.coordinatesAreFilled = false;
    this.checkValidation();
  }
}
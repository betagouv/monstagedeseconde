import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = [
    'mandatoryField',
    'disabledField'
  ];

  static values = {
    minimumLength: Number
  }

  fieldChange(event){
    this.checkValidation();
  }

  allMandatoryFieldsAreFilled(){
    let allFilled = true;
    this.mandatoryFieldTargets.forEach((field) => {
      if (field.value.length <= this.minimumLengthValue) {
        allFilled = false;
      }
    });
    return allFilled;
  }

  setAllDisabledFields(status){
    const disabledFields = this.disabledFieldTargets;
    disabledFields.forEach((field) => {
      field.disabled = status;
    });
  }

  checkValidation(){
    if( this.allMandatoryFieldsAreFilled() ){
      this.setAllDisabledFields(false);
    } else {
      this.setAllDisabledFields(true);
    }
  }

  mandatoryFieldTargetConnected(){
    this.checkValidation();
  }
}
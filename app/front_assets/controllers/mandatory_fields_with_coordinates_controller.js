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
    maximumLength: Number,
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
      // Per-field minimum length (data-mf-min-length) so each field uses its own
      // rule (e.g. title just non-empty, description >= 10) instead of a single
      // shared minimum. Falls back to the controller-wide minimumLength.
      const perFieldMin = field.dataset.mfMinLength;
      const minLength = (perFieldMin !== undefined && perFieldMin !== '')
        ? parseInt(perFieldMin, 10)
        : this.minimumLengthValue;

      if (field.value.trim().length < minLength) {
        allMandatoryFieldsAreFilled = false;
      }
      if (field.value.length > this.maximumLengthValue) {
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

  disconnect(){
    detach(EVENT_LIST.COORDINATES_CHANGED,this.coordinatesChanged.bind(this));
  }
}
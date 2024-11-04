import { Controller } from 'stimulus';
import $ from 'jquery';
import { hide, showSlow, hideElement } from '../utils/dom';

export default class extends Controller {
  static targets = [
    'groupNamePublic',
    'selectGroupName',
  ];

  handleClickIsPublic(event) {
    const isPublic = event.target.value === 'true';
    this.toggleGroupNames(isPublic);
  }

  async isElementLoaded(selector){
    while ( document.querySelector(selector) === null && selector.classList.contains('d-none') ) {
      await new Promise( resolve =>  requestAnimationFrame(resolve) )
    }
    return document.querySelector(selector);
  }

  toggleGroupNames(isPublic) {
    if (isPublic) {
      this.groupNamePublicTarget.classList.remove('d-none');
      hide($(this.groupNamePublicTarget));
      this.isElementLoaded('div[data-ministry-fields-target="groupNamePublic"]')
          .then( (element) => {
        showSlow($(this.groupNamePublicTarget));
      });
    } else {
      hideElement($(this.groupNamePublicTarget));
    }
  }

  groupNamePublicTargetConnected(element) {
    this.toggleGroupNames(false);
  }

}
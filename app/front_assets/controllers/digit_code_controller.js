import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['code', 'button', 'codeContainer'];
  static values = { position: Number };

  onKeyUp(event) {
    event.preventDefault();
    if (event.key === 'Shift') return;
    const isBackKey = event.key === 'Backspace' || event.key === 'ArrowLeft';
    isBackKey ? this.handleBackKey(event) : this.handleForwardKey(event);
    this.updateFocus(event);
  }

  handleBackKey(event) {
    this.clearCurrentKey(event);
    if (!this.isFirstPosition()) this.moveFocus(event, -1);
  }

  handleForwardKey(event) {
    if (this.isNumericKey(event)) {
      this.assignKey(event);
      this.isLastPosition() ? this.enableForm() : this.moveFocus(event, 1);
    } else {
      this.clearCurrentKey(event);
    }
  }

  isNumericKey(event) { return /^\d$/.test(event.key); }

  assignKey(event) { this.currentCodeTarget().value = event.key; }

  clearCurrentKey(event) { this.currentCodeTarget().value = ''; }

  moveFocus(event, direction) { this.positionValue += direction; this.updateFocus(event);
  }

  updateFocus(event) {
    this.disableAllFields();
    this.enableField(this.currentCodeTarget());
    this.currentCodeTarget().focus();
  }

  enableForm() {
    this.buttonTarget.removeAttribute('disabled');
    this.codeContainerTarget.classList.add('finished');
  }

  disableAllFields() { this.codeTargets.forEach(field => field.setAttribute('disabled', true)); }
  enableField(field) { field.removeAttribute('disabled'); }
  currentCodeTarget() { return this.codeTargets[this.positionValue]; }
  isFirstPosition() { return this.positionValue === 0; }
  isLastPosition() { return this.positionValue === this.codeTargets.length - 1; }
}
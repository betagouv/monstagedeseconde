import { Controller } from 'stimulus';
import SignaturePad from 'signature_pad/dist/signature_pad';

export default class extends Controller {
  static targets = ['pad', 'clear', 'submitter', 'signature', 'stampToggle'];

  padTargetConnected(element) {
    const options = {
      minWidth: 1,
      maxWidth: 2,
      penColor: "rgb(0,0,91)"
    }
    this.signaturePad = new SignaturePad(element, options)
    this.signaturePad.addEventListener("beginStroke", () => {
      this.submitterTarget.removeAttribute('disabled');
    });
  }



  clear(event) {
    event.preventDefault();
    this.signaturePad.clear();
    this.signatureTarget.value = '';
    if (!this.stampChecked()) {
      this.submitterTarget.setAttribute('disabled', true);
    }
  }

  toggleStamp() {
    if (this.stampChecked()) {
      this.submitterTarget.removeAttribute('disabled');
    } else if (this.signaturePad.isEmpty()) {
      this.submitterTarget.setAttribute('disabled', true);
    }
  }

  stampChecked() {
    return this.hasStampToggleTarget && this.stampToggleTarget.checked;
  }

  save(event) {
    if (!this.stampChecked()) {
      this.signatureTarget.value = this.signaturePad.toDataURL(); // default is png
    }
    this.submitterTarget.removeAttribute('disabled');
  }
}
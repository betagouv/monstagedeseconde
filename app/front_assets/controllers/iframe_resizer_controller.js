import { Controller } from 'stimulus';
import { iFrameResize } from 'iframe-resizer';

export default class extends Controller {
  static targets = ['iframe']

  iframeTargetConnected(){
    iFrameResize({log: true}, this.iframeTarget)
  }
}
import { Controller } from 'stimulus';
import { isMobile } from '../utils/responsive';

export default class extends Controller {

  static targets = ['iframe', 'tile', 'comboSelect']
  wideScreenHeight   = 576
  wideScreenWidth    = 1024
  mobileScreenHeight = 189
  mobileScreenWidth  = 346

  // when selecting value is updated and 'other' tiles class is updated
  select(event) {
    this.commonPreventions(event)
    const info_node = event.currentTarget.firstChild.firstChild
    const id = parseInt(info_node.children[2].innerText, 10)
    this.tileTargets.forEach((el, index) => {
      el.classList.toggle('video-selected', index === id)
      const url = info_node.children[1].innerText
      this.iframeTarget.src = url
      this.setIframeDimensions()
    })
  }

  select_by_html(event) {
    this.commonPreventions(event)
    const url = this.comboSelectTarget.value
    this.iframeTarget.src = url
    this.setIframeDimensions()
  }

  commonPreventions(event){
    event.preventDefault()
    event.stopPropagation()
  }

  setIframeDimensions(){
    if (isMobile()){
      this.iframeTarget.height = this.mobileScreenHeight
      this.iframeTarget.width = this.mobileScreenWidth
    } else {
      this.iframeTarget.height = this.wideScreenHeight
      this.iframeTarget.width = this.wideScreenWidth
    }
  }

  connect(){
    this.tileTargets[0].classList.add('video-selected')
    this.setIframeDimensions()
  }
}
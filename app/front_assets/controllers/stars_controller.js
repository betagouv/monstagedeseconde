import { Controller } from "stimulus";
import { toggleContainer } from "../utils/dom";
import ActionCable from "actioncable";
export default class extends Controller {
  static targets = ["title", "description", "recommendationPanel"];
  // 20 is the max score
  goodEnoughScore = 12;

  onChangeInput(event) {
    const description = event.target.value;
    if (description.length > 10 && description.length % 50 == 0) {
      this.evaluate(event);
    }
  }

  onPaste(event) {
    const clipboardData = event.clipboardData || window.clipboardData;
    this.score(clipboardData.getData('Text'));
  }

  evaluate(event) { this.score(event.target.value); }
  
  score(description) {
    // convention over configuration: score method is to be found in this.channelParams.channel model
    // i.e. ScoreChannel
    this.evaluator.perform("score", {
      description: description,
      title: this.titleTarget.value || "",
      uid: this.channelParams.uid,
    });
  }

  connect() {
    this.descriptionTarget.addEventListener( "blur", this.evaluate.bind(this) );
    this.descriptionTarget.addEventListener("paste", this.onPaste.bind(this));
    this.channelParams = {
      channel: "ScoreChannel",
      uid: Array.from(crypto.getRandomValues(new Uint8Array(16)), (byte) =>
        byte.toString(16).padStart(2, "0")
      ).join(""),
    };
    this.wssClient = ActionCable.createConsumer("/cable");
    this.evaluator = this.wssClient.subscriptions.create(this.channelParams, {
      received: (data) => {
        const score = parseFloat(data.score, 10).toFixed(2);
        const good_enough = score > this.goodEnoughScore;
        const panelClassList =
          this.recommendationPanelTarget.children[0].classList;
        toggleContainer(this.recommendationPanelTarget, !good_enough);
      },
    });

  }

  disconnect() {
    try {
      this.wssClient.disconnect();
    } catch (e) {}
  }
}

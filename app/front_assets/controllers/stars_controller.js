import { Controller } from "stimulus";
import { toggleContainer } from "../utils/dom";
import ActionCable from "actioncable";
export default class extends Controller {
  static targets = [
    "title",
    "description",
    "score",
    "recommendationPanel"
  ];

  onBlurDescriptionInput(event) {
    const description = event.target.value;
    if (description.length > 8 && description.length % 3 == 0) {
      this.evaluator.perform("score", {
        description: description,
        title: this.titleTarget.value || "",
        uid: this.channelParams.uid,
      });
    }
  }

  connect() {
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
        const good_enough = (score > 12);
        const panelClassList = this.recommendationPanelTarget.children[0].classList;
        toggleContainer(this.recommendationPanelTarget, !good_enough);
      }
    });
  }

  disconnect() {
    try {
      this.wssClient.disconnect();
    } catch (e) {}
  }
}

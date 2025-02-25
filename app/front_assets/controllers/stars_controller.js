import { Controller } from "stimulus";
import {showContainer, hideContainer, setValueById} from "../utils/dom";
import ActionCable from 'actioncable';
export default class extends Controller {
  static targets = [
    "title",
    "description",
    "score",
    "star1",
    "star2",
    "star3",
    "star4",
    "star5"
  ];

  onBlurDescriptionInput(event) {
    const description = event.target.value;
    if ((description.length > 8) && ((description.length % 3) == 0)) {
      this.evaluator.perform('score', {
        description: description,
        title: this.titleTarget.value || '',
        uid: this.channelParams.uid
      });
    }
  }

  showStars(score) {
    this.star1Target.style.color = (score >= 1) ? 'orange' : 'black';
    this.star2Target.style.color = (score >= 6) ? 'orange' : 'black';
    this.star3Target.style.color = (score >= 10) ? 'orange' : 'black';
    this.star4Target.style.color = (score >= 14) ? 'orange' : 'black';
    this.star5Target.style.color = (score >= 18.5) ? 'orange' : 'black';
  }

  connect() {
    this.channelParams = {
      channel: "ScoreChannel",
      uid: Math.random().toString(36),
    };
    this.wssClient = ActionCable.createConsumer("/cable");
    this.evaluator = this.wssClient.subscriptions.create(this.channelParams, {
      received: (data) => {
        const score = parseFloat(data.score, 10).toFixed(2);
        this.scoreTarget.innerHTML = score;
        this.showStars(score);
      },
    });
  }

  disconnect() {
    try {
      this.wssClient.disconnect();
    } catch (e) {}
  }
}

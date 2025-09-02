import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = ["bar", "details", "button"]
  static values = { jobId: String }

  treatmentError = false

  connect() {
    this.detailsTarget.innerHTML = "En attente du démarrage de la tâche..."
    this.consumer = createConsumer('/cable')
    this.channelParams = {
      channel: "ProgressChannel",
      job_id: this.jobIdValue
    }
    this.subscription = this.consumer.subscriptions.create( this.channelParams,
      {
      received: (data) => {
        console.log("Data received:", data)
        this.updateBar(data.progress)
        this.updateExplanation(data.progress)
      }
    })
  }

  disconnect() {
    if (this.subscription) {
      consumer.subscriptions.remove(this.subscription)
    }
  }

  updateBar(progress) {
    this.barTarget.classList.remove('fr-hidden')
    if (!Array.isArray(progress) || progress.length === 0) {
      this.barTarget.style.width = `0%`
      this.barTarget.textContent = `0%`
      return
    }
    const last_time_value = progress[progress.length - 1].time_value
    if (last_time_value !== undefined) {
      this.barTarget.style.width = `${Math.ceil(last_time_value)}%`
      this.barTarget.textContent = `${Math.ceil(last_time_value)}%`
    }
    this.buttonTarget.disabled = true
  }

  updateExplanation(progress) {
    this.detailsTarget.innerHTML = ""
    if (!Array.isArray(progress) || progress.length === 0) {
      return
    }
    progress.forEach( (item, _index) => {
      if (item.type === 'header' || item.type === undefined) {
        this.detailsTarget.innerHTML += `<h2 class='message_header'>${item.message_content}</h2>`
      } else if (item.type === 'info') {
        this.detailsTarget.innerHTML += `<p> [${item.type.toUpperCase()}] ${item.message_content}</p>`
      } else if (item.type === 'error') {
        this.barTarget.classList.add('fr-hidden')
        this.detailsTarget.classList.add('treatment-error')
        this.detailsTarget.innerHTML += `<h2>😮</h2><p> ${item.type.toUpperCase()} ! ${item.message_content}</p>`
      }
    })
  }
}
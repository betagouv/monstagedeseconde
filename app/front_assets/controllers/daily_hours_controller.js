import { Controller } from 'stimulus';
import $ from 'jquery';

export default class extends Controller {
  static targets = [
    'weeklyHoursStart',
    'weeklyHoursEnd',
    'dailyHoursStart',
    'dailyHoursEnd',
    'presenceHint',
    'validator',
    'submitButton',
    // Stage partagé : 2 jeux d'horaires (période 1 / période 2) cohabitent dans le
    // formulaire. Ces targets, scoppées à chaque instance du contrôleur, remplacent
    // les anciens sélecteurs jQuery globaux pour éviter les collisions d'IDs.
    // Optionnelles : le stepper mono ne les fournit pas (fallback ci-dessous).
    'weeklyToggle',
    'weeklyContainer',
    'dailyContainer'
  ];

  minimumPresence = 1; // at least 1 day of presence required

  setValidateButton(stateOn = true) {
    // const validateButton = document.getElementById('practicalInfoSubmitButton');

    // validateButton.disabled = !stateOn;
  }

  handleToggleWeeklyPlanning() {
    // Targets scoppées (multi) si disponibles, sinon sélecteurs globaux (mono).
    const isWeekly = this.hasWeeklyToggleTarget
      ? this.weeklyToggleTarget.checked
      : $('#weekly_planning').is(":checked");
    const weeklyContainer = this.hasWeeklyContainerTarget
      ? this.weeklyContainerTarget
      : document.getElementById('weekly-planning');
    const dailyContainer = this.hasDailyContainerTarget
      ? this.dailyContainerTarget
      : document.getElementById('daily-planning-container');

    if (isWeekly) {
      this.clean_daily_hours()
      dailyContainer.classList.add('d-none')
      $(dailyContainer).hide()
      weeklyContainer.classList.remove('d-none')
      $(weeklyContainer).slideDown()
    } else {
      this.clean_weekly_hours()
      weeklyContainer.classList.add('d-none')
      $(weeklyContainer).hide()
      dailyContainer.classList.remove('d-none')
      $(dailyContainer).slideDown()
    }
    this.checkEnoughPresence();
    this.setValidateButton(false);
  }

  weeklyStartChange() {
    const start = this.getIFromTime(this.weeklyHoursStartTarget.value);

    if (start) {
      Array.from(this.weeklyHoursEndTarget.options).forEach(opt => {
        if (this.getIFromTime(opt.value) < start + 4) {
          opt.disabled = true;
        }
      });
    } else {
      this.enableAllOptions(this.weeklyHoursEndTarget);
    }
    this.weeklyHoursEndTarget.disabled = false;
    this.checkWeeklyPresence();
  }

  weeklyEndChange() {
    const end = this.getIFromTime(this.weeklyHoursEndTarget.value);

    if (end) {
      Array.from(this.weeklyHoursStartTarget.options).forEach(opt => {
        if (this.getIFromTime(opt.value) > end - 4) {
          opt.disabled = true;
        } else {
          opt.disabled = false;
        }
      });
    } else {
      this.enableAllOptions(this.weeklyHoursStartTarget);
    }
    this.weeklyHoursStartTarget.disabled = false;
    this.checkWeeklyPresence();
  }

  checkWeeklyPresence() {
    let enoughPresence = false;
    this.setValidateButton(enoughPresence);
    const start = this.getIFromTime(this.weeklyHoursStartTarget.value);
    const end = this.getIFromTime(this.weeklyHoursEndTarget.value);
    if (start && end) {
      enoughPresence = true;
    }
    this.setValidateButton(enoughPresence);
  }


  dailyHoursStartChange(event) {
    const i = event.target.dataset.i
    const start = this.getIFromTime(this.dailyHoursStartTargets[i].value);

    if (start) {
      let dailyHoursEnd = this.dailyHoursEndTargets[i];
      this.disableOptionBeforeStart(dailyHoursEnd, start);
      dailyHoursEnd.disabled = false;
    } else {
      this.dailyHoursEndTargets[i].disabled = false;
      this.enableAllOptions(this.dailyHoursEndTargets[i]);
    }
    this.checkEnoughPresence();
  }

  dailyHoursEndChange(event) {
    const i = event.target.dataset.i;
    const end = this.getIFromTime(this.dailyHoursEndTargets[i].value);

    // if end not Nan
    if (end) {
      const dailyHoursStart = this.dailyHoursStartTargets[i];
      this.disableOptionAfterEnd(dailyHoursStart, end);
      dailyHoursStart.disabled = false;
    } else {
      this.dailyHoursStartTargets[i].disabled = false;
      this.enableAllOptions(this.dailyHoursStartTargets[i]);
    }
    this.checkEnoughPresence();
  }

  checkEnoughPresence() {
    let daysCounter = 0;
    this.dailyHoursStartTargets.forEach((dailyHoursStartTarget, i) => {
      if (dailyHoursStartTarget.value !== '' && this.dailyHoursEndTargets[i].value !== '') {
        daysCounter += 1;
      }
    });
    const enoughPresence = daysCounter >= this.minimumPresence;
    if (this.hasPresenceHintTarget) {
      if (enoughPresence) {
        this.presenceHintTarget.classList.add('d-none');
      } else {
        this.presenceHintTarget.classList.remove('d-none');
      }
    }
    if (this.hasValidatorTarget) {
      const newValue = enoughPresence ? 'day_selected' : '';
      if (this.validatorTarget.value !== newValue) {
        this.validatorTarget.value = newValue;
        this.validatorTarget.dispatchEvent(new Event('change', { bubbles: true }));
      }
    }
    this.setValidateButton(enoughPresence);
  }

  disableOptionBeforeStart(element, start) {
    Array.from(element.options).forEach(opt => {
      opt.disabled = (this.getIFromTime(opt.value) < start + 4)
    });
  }

  disableOptionAfterEnd(element, end) {
    Array.from(element.options).forEach(opt => {
      if (this.getIFromTime(opt.value) > end - 4) {
        opt.disabled = true;
      }
    });
  }

  enableAllOptions(element) {
    Array.from(element.options).forEach(opt => {
      opt.disabled = false;
    });
  }

  formatTime(i) {
    var hour = Math.floor(i / 4);
    var min = 15 * (i - (hour * 4));
    return `${this.formatNumber(hour)}:${this.formatNumber(min)}`;
  }

  formatNumber(number) {
    if (number < 10) {
      return `0${number}`;
    } else {
      return `${number}`;
    }
  }

  getIFromTime(time) {
    var hour = parseInt(time.split(':')[0]);
    var min = parseInt(time.split(':')[1]);
    return hour * 4 + min / 15;
  }

  clean_daily_hours() {
    this.dailyHoursStartTargets.forEach((dailyHoursStartTarget) => {
      dailyHoursStartTarget.value = '';
    })

    this.dailyHoursEndTargets.forEach((dailyHoursEndTarget) => {
      dailyHoursEndTarget.value = '';
    })
  };


  initialize_daily_hours() {
    for (var i = 0; i < this.dailyHoursStartTargets.length; i++) {
      this.dailyHoursStartTargets[i].value = '09:00';
    }
    for (var j = 0; j < this.dailyHoursEndTargets.length; j++) {
      this.dailyHoursEndTargets[j].value = '17:00';
    }
  }

  clean_weekly_hours() {
    this.weeklyHoursStartTarget.value = '';
    this.weeklyHoursEndTarget.value = '';
  }

  connect() {
    this.checkEnoughPresence();
  }
}

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
    'error',
    'errorGroup',
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
    this.clearHoursError();
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
    this.refreshHoursError();
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
    let completeDays = 0;
    let partialDays = 0;
    this.dailyHoursStartTargets.forEach((dailyHoursStartTarget, i) => {
      const hasStart = dailyHoursStartTarget.value !== '';
      const hasEnd = this.dailyHoursEndTargets[i].value !== '';
      if (hasStart && hasEnd) {
        completeDays += 1;
      } else if (hasStart || hasEnd) {
        partialDays += 1;
      }
    });
    const enoughPresence = completeDays >= this.minimumPresence && partialDays === 0;
    if (this.hasPresenceHintTarget) {
      this.presenceHintTarget.classList.toggle('d-none', enoughPresence);
    }
    if (this.hasValidatorTarget) {
      const newValue = enoughPresence ? 'day_selected' : '';
      if (this.validatorTarget.value !== newValue) {
        this.validatorTarget.value = newValue;
        this.validatorTarget.dispatchEvent(new Event('change', { bubbles: true }));
      }
    }
    this.setValidateButton(enoughPresence);
    this.refreshHoursError();
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
  isWeeklyMode() {
    // Scoped target (multi, 2 instances) when available, global selector (mono) otherwise.
    if (this.hasWeeklyToggleTarget) return this.weeklyToggleTarget.checked;
    const checkbox = document.getElementById('weekly_planning');
    return checkbox ? checkbox.checked : true;
  }

  hoursAreValid() {
    if (this.isWeeklyMode()) {
      return (
        this.hasWeeklyHoursStartTarget &&
        this.hasWeeklyHoursEndTarget &&
        Boolean(this.weeklyHoursStartTarget.value) &&
        Boolean(this.weeklyHoursEndTarget.value)
      );
    }
    return this.hasValidatorTarget && this.validatorTarget.value === 'day_selected';
  }

  validate() {
    if (this.hoursAreValid()) {
      this.clearHoursError();
      return true;
    }
    this.showHoursError();
    return false;
  }

  showHoursError() {
    if (this.isWeeklyMode()) {
      this.toggleSelectError(this.weeklyHoursStartTarget, !this.weeklyHoursStartTarget.value);
      this.toggleSelectError(this.weeklyHoursEndTarget, !this.weeklyHoursEndTarget.value);
    } else {
      this.dailyHoursStartTargets.forEach((startTarget, i) => {
        const endTarget = this.dailyHoursEndTargets[i];
        const partial = (startTarget.value !== '') !== (endTarget.value !== '');
        this.toggleSelectError(startTarget, partial && startTarget.value === '');
        this.toggleSelectError(endTarget, partial && endTarget.value === '');
      });
    }
    
    if (this.hasErrorGroupTarget) this.errorGroupTarget.classList.add('fr-input-group--error');
    if (this.hasErrorTarget) this.errorTarget.classList.remove('fr-hidden');
  }

  clearHoursError() {
    if (this.hasWeeklyHoursStartTarget) this.toggleSelectError(this.weeklyHoursStartTarget, false);
    if (this.hasWeeklyHoursEndTarget) this.toggleSelectError(this.weeklyHoursEndTarget, false);
    this.dailyHoursStartTargets.forEach((t) => this.toggleSelectError(t, false));
    this.dailyHoursEndTargets.forEach((t) => this.toggleSelectError(t, false));
    if (this.hasErrorGroupTarget) this.errorGroupTarget.classList.remove('fr-input-group--error');
    if (this.hasErrorTarget) this.errorTarget.classList.add('fr-hidden');
  }

  // Re-valide uniquement si l'erreur est déjà affichée (effacement « live » après
  // un premier clic en erreur), sans afficher l'erreur pendant la saisie initiale.
  refreshHoursError() {
    if (!this.hasErrorTarget || this.errorTarget.classList.contains('fr-hidden')) return;
    this.validate();
  }

  toggleSelectError(select, on) {
    if (select) select.classList.toggle('fr-select--error', on);
  }

  connect() {
    this.checkEnoughPresence();
  }
}

import $ from 'jquery';
import { Controller } from 'stimulus';

export default class extends Controller {
  connect() {
    // Add the following line to the connect method
    const $maintenanceContactForm = $('#maintenance-contact-form');

    $maintenanceContactForm.ZammadForm({
      messageTitle: "Pour contacter l'équipe 1jeune1solution, remplissez le formulaire ci-dessous :",
      messageSubmit: 'Envoyer',
      messageThankYou:
        'Merci pour votre requête  (#%s) ! Nous vous recontacterons dans les meilleurs délais.',
      showTitle: true,
      attachmentSupport: true,
    });

    $maintenanceContactForm.find('button[type="submit"]').addClass('fr-btn');
  }
}

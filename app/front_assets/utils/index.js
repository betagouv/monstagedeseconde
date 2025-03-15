import { Application } from "@hotwired/stimulus";
import { registerControllers } from 'stimulus-vite-helpers';

// Start the Stimulus application.
const application = Application.start();

// Controller files must be named *_controller.js.
const utils  = import.meta.glob('./*.js', { eager: true });
registerControllers(application, utils);
// To see this message, add the following to the `<head>` section in your
// views/layouts/application.html.erb
//
//    <%= vite_client_tag %>
//    <%= vite_javascript_tag 'application' %>
console.log('Vite ⚡️ Rails')

// If using a TypeScript entrypoint file:
//     <%= vite_typescript_tag 'application' %>
//
// If you want to use .jsx or .tsx, add the extension:
//     <%= vite_javascript_tag 'application.jsx' %>

// Example: Load Rails libraries in Vite.

// Turbo
import * as Turbo from '@hotwired/turbo'
Turbo.start()

// js
// react polyfills (ie<11), see: https://reactjs.org/docs/javascript-environment-requirements.html
import 'raf/polyfill';
import 'core-js/es/map';
import 'core-js/es/set';
import "core-js/stable";
import "regenerator-runtime/runtime";
import 'bootstrap';
import "~/utils";

//Stimulus started from index.js included file
import '~/controllers';

// css
import '~/stylesheets/variables.scss'
import '~/stylesheets/screen.scss'

import '@gouvfr/dsfr/dist/dsfr.css';
import '@gouvfr/dsfr/dist/utility/icons/icons-system/icons-system.css';
import '@gouvfr/dsfr/dist/utility/icons/icons-user/icons-user.css';
import '@gouvfr/dsfr/dist/utility/icons/icons-business/icons-business.css';
import '@gouvfr/dsfr/dist/utility/icons/icons-design/icons-design.css';
import '@gouvfr/dsfr/dist/utility/icons/icons-document/icons-document.css';
import '@gouvfr/dsfr/dist/utility/icons/icons-media/icons-media.css';
import '@gouvfr/dsfr/dist/utility/colors/colors.css';
import '@gouvfr/dsfr/dist/utility/icons/icons-map/icons-map.css';
import '@gouvfr/dsfr/dist/utility/colors/colors.css';

import '@gouvfr/dsfr/dist/dsfr.module.js';
// const controllers = import.meta.glob('./**/*_controller.js', { eager: true })
// registerControllers(application, controllers)

import ReservedSchoolInput from "~/components/ReservedSchoolInput";
// import InternshipOfferResults from "components/InternshipOfferResults";
// import InternshipOfferFavorites from "components/InternshipOfferFavorites";
// import InternshipOfferCard from "components/InternshipOfferCard";
// import InternshipOfferFavoriteButton from "components/InternshipOfferFavoriteButton";
// import FlashMessage from "components/FlashMessage";
// import SearchSchool from "components/SearchSchool";
// import SearchSchoolByName from "components/SearchSchoolByName";
// import Map from "components/Map";

// import CityInput from "components/search_internship_offer/CityInput";
// import CompanyCityInput from "components/search_internship_offer/CompanyCityInput";
// import KeywordInput from "components/search_internship_offer/KeywordInput";
// import DistanceIcon from "components/icons/DistanceIcon";

// import FullAddressInput from "components/inputs/FullAddressInput";
// import SirenInput from "components/inputs/SirenInput";
// import CountryPhoneSelect from "components/inputs/CountryPhoneSelect";
// import AddressInput from "components/inputs/AddressInput";
// import RomeInput from "components/inputs/RomeInput";
// import '@popperjs/core';

// import '@hotwired/turbo-rails';

// import Alert from 'bootstrap'
// import Dropdown from 'bootstrap'
// import Modal from 'bootstrap'
// import Tooltip from 'bootstrap'

// import "trix";
// import "@rails/actiontext";

// import 'url-search-params-polyfill';

// import '../bootapp';
// import '../leaflet-providers';

// import '../utils/zammad_form';

// import '../utils/confirm';
// import '../components/internship_agreements/button_component.scss'
// import 'trix'
//-----------------------------------
//-----------------------------------
//
// import ActiveStorage from '@rails/activestorage'
// ActiveStorage.start()
//
// // Import all channels.
// const channels = import.meta.globEager('./**/*_channel.js')

// Example: Import a stylesheet in app/frontend/index.css
// import '~/index.css'

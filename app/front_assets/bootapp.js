// rails stack
import '@stimulus/polyfills';
import Rails from 'rails-ujs';
import ReactOnRails from 'react-on-rails';
import { Application } from 'stimulus';
import { definitionsFromContext } from 'stimulus/webpack-helpers';

Rails.start();
const application = Application.start()

const context = require.context('controllers', true, /.js$/)
application.load(definitionsFromContext(context))

// Support component names relative to this directory:
const componentRequireContext = require.context("components", true);

import ReservedSchoolInput from "components/ReservedSchoolInput";
import InternshipOfferResults from "components/InternshipOfferResults";
import InternshipOfferFavorites from "components/InternshipOfferFavorites";
import InternshipOfferCard from "components/InternshipOfferCard";
import InternshipOfferFavoriteButton from "components/InternshipOfferFavoriteButton";
import FlashMessage from "components/FlashMessage";
import SearchSchool from "components/SearchSchool";
import SearchSchoolByName from "components/SearchSchoolByName";
import Map from "components/Map";

import CityInput from "components/search_internship_offer/CityInput";
import GradeInput from "components/search_internship_offer/GradeInput";
import WeekInput from "components/search_internship_offer/WeekInput";
import CompanyCityInput from "components/search_internship_offer/CompanyCityInput";
import KeywordInput from "components/search_internship_offer/KeywordInput";
import SearchBar from "components/search_internship_offer/SearchBar";

import DistanceIcon from "components/icons/DistanceIcon";

import AddressInput from "components/inputs/AddressInput";
import CountryPhoneSelect from "components/inputs/CountryPhoneSelect";
import FullAddressInput from "components/inputs/FullAddressInput";
import RomeInput from "components/inputs/RomeInput";
import SirenInput from "components/inputs/SirenInput";

ReactOnRails.register({
  AddressInput,
  CityInput,
  CompanyCityInput,
  CountryPhoneSelect,
  DistanceIcon,
  FlashMessage,
  FullAddressInput,
  GradeInput,
  InternshipOfferCard,
  InternshipOfferFavoriteButton,
  InternshipOfferFavorites,
  InternshipOfferResults,
  KeywordInput,
  Map,
  ReservedSchoolInput,
  SearchSchool,
  SearchSchoolByName,
  SirenInput,
  RomeInput,
  WeekInput,
  SearchBar
});

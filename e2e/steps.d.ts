/// <reference types='codeceptjs' />
type steps_file = typeof import('./steps_file.js');

declare namespace CodeceptJS {
  interface SupportObject { I: I, current: any, Je: Je }
  interface Methods extends Playwright {}
  interface I extends ReturnType<steps_file> {}
  interface Je extends WithTranslation<Methods> {}
  namespace Translation {
    interface Actions {
  "amOutsideAngularApp": "suisALExtérieurDeLApplicationAngular",
  "amInsideAngularApp": "suisALIntérieurDeLApplicationAngular",
  "waitForElement": "attendsLElément",
  "waitForClickable": "attendsDeCliquer",
  "waitForVisible": "attendsPourVoir",
  "waitForEnabled": "attendsLActivationDe",
  "waitForInvisible": "attendsLInvisibilitéDe",
  "waitInUrl": "attendsDansLUrl",
  "waitForText": "attendsLeTexte",
  "moveTo": "vaisSur",
  "refresh": "rafraîchis",
  "refreshPage": "rafraîchisLaPage",
  "haveModule": "ajouteLeModule",
  "resetModule": "réinitialiseLeModule",
  "amOnPage": "suisSurLaPage",
  "click": "cliqueSur",
  "doubleClick": "doubleCliqueSur",
  "see": "vois",
  "dontSee": "neVoisPas",
  "selectOption": "sélectionneUneOption",
  "fillField": "remplisLeChamp",
  "pressKey": "appuisSurLaTouche",
  "triggerMouseEvent": "déclencheLEvénementDeLaSouris",
  "attachFile": "attacheLeFichier",
  "seeInField": "voisDansLeChamp",
  "dontSeeInField": "neVoisPasDansLeChamp",
  "appendField": "ajouteAuChamp",
  "checkOption": "vérifieLOption",
  "seeCheckboxIsChecked": "voisQueLaCaseEstCochée",
  "dontSeeCheckboxIsChecked": "neVoisPasQueLaCaseEstCochée",
  "grabTextFrom": "prendsLeTexteDe",
  "grabValueFrom": "prendsLaValeurDe",
  "grabAttributeFrom": "prendsLAttributDe",
  "seeInTitle": "voisDansLeTitre",
  "dontSeeInTitle": "neVoisPasDansLeTitre",
  "grabTitle": "prendsLeTitre",
  "seeElement": "voisLElément",
  "dontSeeElement": "neVoisPasLElément",
  "seeInSource": "voisDansLeCodeSource",
  "dontSeeInSource": "neVoisPasDansLeCodeSource",
  "executeScript": "exécuteUnScript",
  "executeAsyncScript": "exécuteUnScriptAsynchrone",
  "seeInCurrentUrl": "voisDansLUrl",
  "dontSeeInCurrentUrl": "neVoisPasDansLUrl",
  "seeCurrentUrlEquals": "voisQueLUrlEstEgaleA",
  "dontSeeCurrentUrlEquals": "neVoisPasQueLUrlEstEgaleA",
  "saveScreenshot": "prendsUneCapture",
  "setCookie": "déposeLeCookie",
  "clearCookie": "effaceLeCookie",
  "seeCookie": "voisLeCookie",
  "dontSeeCookie": "neVoisPasLeCookie",
  "grabCookie": "prendsLeCookie",
  "resizeWindow": "redimensionneLaFenêtre",
  "wait": "attends",
  "clearField": "effaceLeChamp",
  "dontSeeElementInDOM": "neVoisPasDansLeDOM",
  "moveCursorTo": "bougeLeCurseurSur",
  "scrollTo": "défileVers",
  "sendGetRequest": "envoieLaRequêteGet",
  "sendPutRequest": "envoieLaRequêtePut",
  "sendDeleteRequest": "envoieLaRequêteDeleteAvecPayload",
  "sendPostRequest": "envoieLaRequêtePost"
}
  }
}

declare const Fonctionnalité: typeof Feature;
declare const Exemple: typeof Scenario;
declare const Plan du scénario: typeof ScenarioOutline;
declare const Avant: typeof Before;
declare const Après: typeof After;
declare const AvantLaSuite: typeof BeforeSuite;
declare const AprèsLaSuite: typeof AfterSuite;
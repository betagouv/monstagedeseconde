export const isVisible = ($element) => !$element.hasClass('d-none')
export const showElement = ($element) => $element.removeClass('d-none');
export const showSlow = ($element) => $element.show('slow');
export const hideElement = ($element) => $element.addClass('d-none');
export const hide = ($element) => $element.hide();
export const toggleElement = ($element) => $element.toggleClass('d-none');
export const setElementVisibility = ($element, isVisible) => $element.toggleClass('d-none', isVisible);
export const enableInput = ($element) => $element.attr('readonly', false).attr('disabled', false);
export const disableInput = ($element) => $element.attr('readonly', 'readonly').attr('disabled', 'disabled');
export const toggleContainerById = (id, on) => toggleContainer(document.getElementById(id), on);
export const toggleContainer = (el, on) =>{ (on) ? el.classList.remove('d-none') : el.classList.add('d-none')};
export const toggleContainers = (els, on) => {els.forEach(el => toggleContainer(el, on))};
export const setValueById= (id, value) => document.getElementById(id).value = value;


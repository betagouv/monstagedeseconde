import { Turbo } from "@hotwired/turbo-rails";
import $ from 'jquery';

export const fetchSearchParamsFromUrl = () => {
  return new URLSearchParams(window.location.search);
}

export const addParamToSearchParams = (param, paramValue) => {
  const searchParams = fetchSearchParamsFromUrl();
  // No, param name does not have to be terminated with '[]' for URLSearchParams.
  // URLSearchParams will encode multiple values for the same key as repeated keys (e.g., ?foo=1&foo=2).
  // '[]' is sometimes used by conventions (like Rails) to indicate arrays, but it's not required by URLSearchParams.
  if (Array.isArray(paramValue)) {
    if (paramValue.length === 0) {
      searchParams.delete(param);
    } else {
      searchParams.delete(param);
      paramValue.forEach(value => searchParams.append(param, value));
    }
  } else {
    if (!paramValue || paramValue.length === 0) {
      searchParams.delete(param);
    } else {
      searchParams.set(param, paramValue);
    }
  }
  return searchParams;
}

export const removeParam = (param_name) => {
  const searchParams = fetchSearchParamsFromUrl();
  searchParams.delete(param_name);
  return searchParams;
}

// it updates url without reloading the page
export const updateURLWithParam = (searchParams) => {
  window.history.replaceState({}, '', `${window.location.pathname}?${searchParams.toString()}`);
}

export const changeURLFromEvent = (event, param) => {
  visitURLWithParam(param, $(event.target).val());
}

export const visitURLWithParam = (param, paramValue) => {
  const searchParamsToClear = ['school_id', 'page']
  const searchParams = clear(searchParamsToClear)
  // other search params are kept as they were
  if (paramValue.length === 0) {
    searchParams.delete(param);
  } else {
    searchParams.set(param, paramValue);
  }
  turboVisitsWithSearchParams(searchParams)
}

export const visitURLWithOneParam = (param, paramValue) => {
  const searchParams = clearAllParams();
  searchParams.set(param, paramValue);
  turboVisitsWithSearchParams(searchParams);
}

export const searchParamsFromHash = (hash) => {
  const searchParams = clearAllParams();
  Object.keys(hash).forEach((key) => {
    searchParams.set(key, hash[key]);
  });
  return searchParams;
}

export const clearSearch = () => {
  turboVisitsWithSearchParams(clearAllParams());
}

export const turboVisitsWithSearchParams = (searchParams) => {
  Turbo.visit(
    `${window.location.origin}${window.location.pathname}?${searchParams.toString()}`,
  );
}



export const clearParamAndVisits = (param_name )=> {
  turboVisitsWithSearchParams(removeParam(param_name));
}

export const getParamValueFromUrl = (param) => {
  const searchParams = fetchSearchParamsFromUrl();
  for (const [key, value] of searchParams.entries()) {
    if (key === param) { return value }
  }
  return undefined
}

export const parseArrayValueFromUrl = (param) => {
  // example : latitude=&longitude=&city=&radius=60000&week_ids=340&week_ids=339
  // it is to return [339,340] as a sorted array
  // if param is not found, it returns an empty array
  // if param is found with one value, it returns an array with one value
  // if param is found with multiple values, it returns an array with all values
  const searchParams = fetchSearchParamsFromUrl();
  const values = searchParams.getAll(param);
  if (values.length === 0) {
    return [];
  }
  return values.map(value => parseInt(value, 10))
               .filter(value => !isNaN(value))
               .sort((a, b) => a - b);
}

// private

const clear = (list) => {
  const searchParams = fetchSearchParamsFromUrl();
  for (var i = 0; i < list.length; i++) {
    searchParams.delete(list[i])
  }
  return searchParams;
}

const clearAllParams = () => {
  const searchParams = fetchSearchParamsFromUrl();
  let list = []
  for (var key of searchParams.keys()) { list.push(key) }
  return clear(list);
}
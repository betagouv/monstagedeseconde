import React, { useEffect, useState } from 'react';
import { useDebounce } from 'use-debounce';
// import { throttle, debounce } from "throttle-debounce";
import Downshift from 'downshift';
import { fetch } from 'whatwg-fetch';
import { endpoints } from '../../utils/api';

export default function RomeInput({
  currentKeyword,
  currentLatitude,
  currentLongitude
}) {
  const searchParams = new URLSearchParams(window.location.search);
  const [searchResults, setSearchResults] = useState([]);
  const [keyword, setKeyword] = useState(currentKeyword || searchParams.get('coded_crafts') || '');
  const [ogrCode, setOgrCode] = useState('');
  const [keywordDebounced] = useDebounce(keyword, 200);

const inputChange = (event) => {
  setKeyword(event.target.value);
};

const resetField = () => {
  searchParams.delete('coded_crafts');
  setKeyword('');
};

const searchRomeByKeyword = () => {
  fetch(endpoints.apiRomeQuery({ keyword: keywordDebounced }))
    .then((response) => response.json())
    .then((json) => {
      setSearchResults(json)
    }) ;
};

const setResultComponents = (item) => {
  setKeyword(item.name);
  setOgrCode(item.ogr_code);
  if (item.name === undefined) {
    setKeyword(item.pg_search_highlight_name);
  } else {
    setKeyword(item.name);
  };
}

useEffect(() => {
  if (keywordDebounced && keywordDebounced.length >= 3) {
    searchRomeByKeyword()
  }
}, [keywordDebounced]);

return (
  <div>
    <input type='hidden' name='appellationCode' value={ogrCode} />
    <div className="form-group mb-md-0 col-12 col-md" id="test-input-craft-by-keyword">
      <div className="container-downshift">
        <Downshift
          initialInputValue={keyword}
          onChange={setResultComponents}
          selectedItem = {keyword}
          itemToString={(item) => { item && item.name ? item.name : ''; }}
        >
         {({
            getLabelProps,
            getInputProps,
            getItemProps,
            getMenuProps,
            isOpen,
            highlightedIndex,
            selectedItem,
            getRootProps,
          }) => (
            <div>
              <label
                {...getLabelProps({
                  className: 'fr-label font-weight-lighter',
                  htmlFor: 'coded_crafts',
                })}
              >
                Métier recherché
              </label>

              <div>
                <input
                  {...getInputProps({
                    onChange: inputChange,
                    onClick:  (e) => {resetField()},
                    value: keyword,
                    className: 'fr-input',
                    name: 'coded_crafts',
                    id: 'coded_crafts',
                    placeholder: '2 car. minimum - optionnel',
                  })}
                />
              </div>
              <div>
                <div className="search-in-place bg-white shadow">
                  <ul
                    {...getMenuProps({
                      className: 'p-0 m-0',
                    })}
                  >
                    { isOpen
                      ? searchResults.map((item, index) => (
                        <li
                          {...getItemProps({
                            className: `py-2 px-3 listview-item ${
                              highlightedIndex === index ? 'highlighted-listview-item' : ''
                            }`,
                            key: `${item.id}-${item.name}`,
                            index,
                            item,
                            style: { fontWeight: highlightedIndex === index? 'bold' : 'normal' },
                          })}
                        >
                          <div dangerouslySetInnerHTML={{__html: item.pg_search_highlight_name}}></div>
                        </li>
                          ))
                        : null}
                  </ul>
                </div>
              </div>
            </div>
          )}
        </Downshift>
      </div>
    </div>
  </div>
);
}

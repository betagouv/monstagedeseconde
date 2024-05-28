import React from 'react';

function Paginator({ paginateLinks }) {
  function pageUrl(pageId) {
    return paginateLinks.pageUrlBase + '&page=' + pageId
  };

  return (
  <div className='fr-mt-1w'>
    <nav role="navigation" className="fr-pagination" aria-label="Pagination">
      <ul className="fr-pagination__list d-flex justify-content-center">
        {/* PREVIOUS PAGE */}
        { paginateLinks ? (
            paginateLinks.isFirstPage ? '' : (
              <li>
                <a href={pageUrl(paginateLinks.prevPage)} className="fr-pagination__link fr-pagination__link--prev fr-pagination__link--lg-label" aria-disabled="false" role="link">
                  Page précédente
                </a>
              </li>
              
            )
          ) : ''
        }

         {/* FIRST PAGE NUMBER */}
         { 
          paginateLinks.isFirstPage ? '' : (
            <li>
              <a href={pageUrl(1)} className="fr-pagination__link fr-displayed-lg" title="Page 1">
                1
              </a>
            </li>
          )
        }       

         {/* MIDDLE */}
         { 
          parseInt(paginateLinks.currentPage) < 4 ? '' : (
            <li className='fr-pagination__link fr-displayed-lg'>...</li>
          ) 
        }

        {/* PREVIOUS PAGE NUMBER */}
        { 
          paginateLinks.currentPage == '2' ? '' : (
            <li>
              <a href={pageUrl(paginateLinks.prevPage)} className="fr-pagination__link fr-displayed-lg"  title={`Page ${paginateLinks.prevPage}`}>
                {paginateLinks.prevPage}
              </a>
            </li>
          )
        }

        {/* CURRENT PAGE */}
        <li>
          <a className="fr-pagination__link" aria-current="page" title={`Page ${paginateLinks.currentPage}`}>
            {paginateLinks.currentPage}
          </a>
        </li>

        {/* NEXT PAGE NUMBER */}
        { 
          paginateLinks.isLastPage || (paginateLinks.nextPage == paginateLinks.totalPages) ? '' : (
            <li>
              <a href={pageUrl(paginateLinks.nextPage)} className="fr-pagination__link fr-displayed-lg" title={`Page ${paginateLinks.nextPage}`}>
                {paginateLinks.nextPage}
              </a>
            </li>
          )
        }

        {/* MIDDLE */}
        {
          paginateLinks.isLastPage || (paginateLinks.nextPage == paginateLinks.totalPages) ? '' : (
            <li className='fr-pagination__link fr-displayed-lg'>...</li>
          ) 
        }
    

        {/* LAST NUMBER PAGE */}
        { 
          paginateLinks.isLastPage ? '' : (
            <li>
              <a href={pageUrl(paginateLinks.totalPages)} className="fr-pagination__link fr-displayed-lg" title={`Page ${paginateLinks.totalPages}`}>
                {paginateLinks.totalPages}
              </a>
            </li>
          )
        }

        {/* NEXT PAGE */}

        { 
          paginateLinks.isLastPage ? '' : (
            <li>
              <a href={pageUrl(paginateLinks.nextPage)} className="fr-pagination__link fr-pagination__link--next fr-pagination__link--lg-label">
                Page suivante
              </a>
            </li>
          )
        }
      </ul>
    </nav>
  </div>
  )
};

export default Paginator;
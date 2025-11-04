module Api::V2
  module FinderPagination
    private
    def paginate(scope)
      page = (params[:page] || 1).to_i
      per_page = (params[:per_page] || 20).to_i

      paginated_scope = scope.page(page).per(per_page)

      @page_links = {
        current_page: paginated_scope.current_page,
        next_page: paginated_scope.next_page,
        prev_page: paginated_scope.prev_page,
        total_pages: paginated_scope.total_pages,
        total_count: paginated_scope.total_count,
        per_page: paginated_scope.limit_value
      }

      paginated_scope
    end
  end
end
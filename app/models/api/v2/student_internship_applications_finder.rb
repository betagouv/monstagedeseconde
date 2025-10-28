module Api::V2
  class StudentInternshipApplicationsFinder
    include Api::V2::FinderPagination

    attr_reader :student, :api_user, :page, :per_page, :page_links

    def initialize(student:, api_user:, page: 1, per_page: 20)
      @student = student
      @api_user = api_user
      @page = page.to_i
      @per_page = per_page.to_i
      @page_links = {}
    end

    def all
      scope = InternshipApplication.where(user_id: student.id)

      paginate(page: page, per_page: per_page, scope: scope.order(id: :desc))
    end

    def page_links
      @page_links
    end

    def paginate(page:, per_page:, scope:)

      paginated_scope = scope.page(page).per(per_page)

      @page_links = {
        current_page: paginated_scope.current_page,
        next_page: paginated_scope.next_page,
        prev_page: paginated_scope.prev_page,
        total_pages: paginated_scope.total_pages,
        total_count: paginated_scope.total_count,
        per_page: paginated_scope.limit_value
      }

      {internship_applications: paginated_scope, page_links: @page_links}
    end
  end
end

# frozen_string_literal: true

module ReportingHelper
  def default_reporting_url_options(user, extra = {})
    opts = {}
    return opts unless user

    opts[:department] = user.department if user.department.present?
    opts[:school_year] = params[:school_year] || SchoolYear::Current.new.beginning_of_period.year
    opts[:subscribed_school] = opts[:subscribed_school] || false
    opts.merge!(extra) unless extra.blank?
    opts
  end

  def stats_breadcrumb_links(params:, user:)
    breadcrumb = [[reporting_internship_offers_path(default_reporting_url_options(user)), 'Statistiques']]
    if params[:department].present? && params[:group].present?
      breadcrumb << [[reporting_internship_offers_path(department: params[:department]), params[:department]],
                     ['', params[:group]]]
    elsif params[:department].present?
      breadcrumb << if params[:department].is_a?(Array)
                      [['', user.try(:academy)&.name || user.academy_region&.name]]
                    else
                      [['', params[:department]]]
                    end
    elsif params[:group].present?
      breadcrumb << [['', params[:group]]]
    else
      breadcrumb = [['', 'Statistiques nationales']] # replacement
    end
    breadcrumb
  end
end

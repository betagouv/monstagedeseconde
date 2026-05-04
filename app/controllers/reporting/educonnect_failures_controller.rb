module Reporting
  class EduconnectFailuresController < ApplicationController
    before_action :authenticate_user!
    FAILURE_SIZE_WARNING_THRESHOLD = 100
    FAILURE_SIZE_WARNING_LIMIT = 1_000

    def index
      authorize! :see_educonnect_failures, EventReport
      authorize! :index, Acl::Reporting.new(user: current_user, params: params)

      @educonnect_failures = EventReport.order(created_at: :desc)
      failures_count = @educonnect_failures.count

      if failures_count.zero?
        flash.now[:notice] = "Aucune échec de connexion Educonnect n'a été enregistré pour le moment."
      else
        if failures_count > FAILURE_SIZE_WARNING_LIMIT
          # delete overhead failures to avoid performance issues
          excess_failures = @educonnect_failures.offset(FAILURE_SIZE_WARNING_LIMIT)
          excess_failures.delete_all
          @educonnect_failures = @educonnect_failures.limit(FAILURE_SIZE_WARNING_LIMIT)
          flash.now[:alert] = "Il y a actuellement plus de #{FAILURE_SIZE_WARNING_LIMIT} échec(s) de connexion Educonnect enregistré(s). Les plus anciens ont été supprimés pour éviter des problèmes de performance."
        elsif failures_count > FAILURE_SIZE_WARNING_THRESHOLD
          flash.now[:alert] = "Il y a actuellement #{failures_count} échec(s) de connexion Educonnect enregistré(s)."
        else
          flash.now[:notice] = "Il y a actuellement #{failures_count} échec(s) de connexion Educonnect enregistré(s)."
        end
      end
    end
  end
end

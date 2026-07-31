require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdmin
  module Config
    module Actions
      class ImportStudentsFromSygne < Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :visible? do
          authorized? && bindings[:object].is_a?(School)
        end

        register_instance_option :member do
          true
        end

        register_instance_option :link_icon do
          'fas fa-file-import'
        end

        register_instance_option :pjax? do
          false
        end

        register_instance_option :controller do
          proc do
            CountStudentsFromSygneJob.perform_later(@object)
            flash[:success] = "Recomptage des effectifs depuis Sygne lancé pour #{@object.name}."
            redirect_to show_path(model_name: 'school', id: @object.id)
          end
        end
      end
    end
  end
end

require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdmin
  module Config
    module Actions
      class Publish < Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :visible? do
          authorized? && bindings[:object].is_a?(InternshipOffers::WeeklyFramed)
        end

        register_instance_option :member do
          true
        end

        register_instance_option :link_icon do
          bindings[:object].published? ? 'fas fa-eye' : 'fas fa-eye-slash'
        end

        # You may or may not want pjax for your action
        register_instance_option :pjax? do
          true
        end

        register_instance_option :controller do
          proc do
            if @object.may_publish?
              @object.publish!
              flash[:success] = t('flash.actions.publish.success')
            elsif @object.may_unpublish?
              @object.unpublish!
              flash[:success] = t('flash.actions.unpublish.success')
            else
              flash[:error] = t('flash.actions.publish.error')
            end
            redirect_to index_path(model_name: 'internship_offers~weekly_framed')
          end
        end
      end
    end
  end
end

module AdminInappropriateOfferable
  extend ActiveSupport::Concern

  included do
    rails_admin do
      navigation_label 'Signalements'
      label do
        'Offres signalées'
      end

      list do
        field :created_at do
          label { 'Date du signalement' }
        end

        # field :ground do
        #   label { 'Motif' }

        #   pretty_value do
        #     InappropriateOffer.options_for_ground[value] || value
        #   end

        #   register_instance_option :filter_operators do
        #     %w[_discard] +
        #     InappropriateOffer.options_for_ground.map { |key, french_label| { label: french_label, value: key } } +
        #     (required? ? [] : %w[_separator _present _blank])
        #   end
        # end

        field :internship_offer do
          label { 'Offre de stage' }
          pretty_value do
            bindings[:view].link_to(
              bindings[:object].internship_offer.title.to_s,
              Rails.application.routes.url_helpers.internship_offer_url(
                bindings[:object].internship_offer_id,
                **Rails.configuration.action_mailer.default_url_options,
                target: '_blank'
              )
            )
          end
        end

        field :moderator do
          label {'Traité par'}
        end

        field :moderation_action do
          label { 'Action choisie' }
          pretty_value do
            if value.present?
              InappropriateOffer.options_for_moderation_action[value] || value
            else
              bindings[:view].content_tag(:span, 'En attente', class: 'badge bg-warning text-white')
            end
          end
        end

          # add status internship offer
        field :status_internship_offer do
          label { 'Offre de stage' }
          pretty_value do
            if bindings[:object].internship_offer.discarded?
              bindings[:view].content_tag(:span, 'Supprimée', class: 'badge bg-danger text-white')
            elsif bindings[:object].internship_offer.published_at.blank?
              bindings[:view].content_tag(:span, 'Masquée', class: 'badge bg-secondary text-white')
            else
              bindings[:view].content_tag(:span, 'Publiée', class: 'badge bg-success text-white')
            end
          end
        end

        field :actions do
          label { 'Actions' }
          sortable false
          searchable false
          
          formatted_value do
            bindings[:view].link_to(
              Rails.application.routes.url_helpers.manage_inappropriate_offer_path(
                bindings[:object].id
              ),
              class: 'btn btn-sm btn-primary',
              title: 'Modérer ce signalement'
            ) do
              bindings[:view].content_tag(:i, '', class: 'fa fa-gavel') +
              ' Modérer'
            end
          end
        end
      end

      show do
        field :created_at do
          label { 'Date du signalement' }
          date_format 'KO'
          strftime_format '%d/%m/%Y'
        end

        field :ground do
          label { 'Motif' }

          pretty_value do
            InappropriateOffer.options_for_ground[value] || value
          end
        end

        register_instance_option :filter_operators do
          %w[_discard] +
          InappropriateOffer.options_for_ground.map { |key, french_label| { label: french_label, value: key } } +
          (required? ? [] : %w[_separator _present _blank])
        end

        field :details do
          label { 'Détails' }
        end

        field :internship_offer do
          label { 'Offre de stage' }
          pretty_value do
            bindings[:view].link_to(
              bindings[:object].internship_offer.title.to_s,
              Rails.application.routes.url_helpers.internship_offer_url(
                bindings[:object].internship_offer_id,
                **Rails.configuration.action_mailer.default_url_options,
                target: '_blank'
              )
            )
          end
        end

        field :user do
          label {'Levé par'}
        end

        field :moderation_action do
          label { 'Action de modération' }
          pretty_value do
            if value.present?
              InappropriateOffer.options_for_moderation_action[value] || value
            else
              'Non modéré'
            end
          end
        end

        field :moderator do
          label { 'Modéré par' }
          pretty_value do
            if bindings[:object].moderator.present?
              bindings[:object].moderator.email
            else
              'Non assigné'
            end
          end
        end

        field :decision_date do
          label { 'Date de décision' }
        end

        field :message_to_employer do
          label { 'Message à l\'employeur' }
        end

        field :internal_comment do
          label { 'Commentaire interne' }
        end
      end
    end
  end
end
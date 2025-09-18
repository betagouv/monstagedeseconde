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

        field :ground do
          label { 'Motif' }

          pretty_value do
            InappropriateOffer.options_for_ground[value] || value
          end

          register_instance_option :filter_operators do
            %w[_discard] +
            InappropriateOffer.options_for_ground.map { |key, french_label| { label: french_label, value: key } } +
            (required? ? [] : %w[_separator _present _blank])
          end
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
      end
    end
  end
end
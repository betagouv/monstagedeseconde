# frozen_string_literal: true

class Operator < ApplicationRecord
  has_many :operators, class_name: 'Users::Operator'
  has_many :internship_offers, through: :operators
  has_many :departments_operators
  has_many :departments, through: :departments_operators

  rails_admin do
    weight 15
    navigation_label 'Divers'

    list do
      field :name
      field :target_count
      field :open_data do
        def label = 'Open Data'
      end
      field :masked_data do
        def label = 'Données masquées'
      end
    end
    show do
      field :name
      field :target_count
      field :logo
      field :website
      field :open_data do
        def label = 'Open Data'
      end
      field :masked_data do
        def label = 'Données masquées'
      end
    end

    edit do
      field :name
      field :target_count
      field :logo
      field :website
      field :open_data do
        def label = 'Open Data'
      end
      field :masked_data do
        def label = 'Données masquées'
      end
    end
  end
end

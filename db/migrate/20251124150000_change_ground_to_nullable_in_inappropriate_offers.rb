# frozen_string_literal: true

class ChangeGroundToNullableInInappropriateOffers < ActiveRecord::Migration[7.1]
  def up
    change_column_null :inappropriate_offers, :ground, true
  end

  def down
    change_column_null :inappropriate_offers, :ground, false
  end
end


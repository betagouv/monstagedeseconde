class ConfigureFlipperForMaintenanceModes < ActiveRecord::Migration[7.1]
  def up
    return if Rails.env.test?

    Flipper.enable(:student_update_feature)
    Flipper.enable(:holidays_maintenance)
    Flipper.enable(:maintenance_mode)

    # Remove the feature if it exists
    Flipper.disable(:holidays_maintenance) if Flipper.enabled?(:holidays_maintenance)
    Flipper.disable(:maintenance_mode) if Flipper.enabled?(:maintenance_mode)
  end

  def down
  end
end

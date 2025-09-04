
require 'flipper'
require 'flipper/adapters/memory'

def import_flipper_local_file
  seed = Flipper.new(Flipper::Adapters::Memory.new)
  seed.disable(:holidays_maintenance)
  seed.disable(:application_inhibited)
  seed.disable(:disable_students_connexion_button)
  # keep following lines commented out, they are for future use
  # seed.enable_percentage_of_time(:verbose_logging, 5)
  # seed.enable_percentage_of_actors(:new_feature, 5)
  # seed.enable_actor(:issues, Flipper::Actor.new('1'))
  # seed.enable_actor(:issues, Flipper::Actor.new('2'))
  # seed.enable_group(:request_tracing, :staff)

  Flipper.import(seed.export)
end


call_method_with_metrics_tracking(%i[ import_flipper_local_file ])
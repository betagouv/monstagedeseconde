# frozen_string_literal: true

require 'csv'
require_relative '../test/support/coordinates'
require 'ffaker'
require 'active_support/notifications'
require 'pretty_console'

def siret
  siret = FFaker::CompanyFR.siret
  siret.gsub(/[^0-9]/, '')
end

def geo_point_factory_array(coordinates_as_array)
  type = { geo_type: 'point' }
  factory = RGeo::ActiveRecord::SpatialFactoryStore.instance
                                                   .factory(type)
  factory.point(*coordinates_as_array)
end

def random_extra_attributes(object)
  return if object.valid? && object.persisted?

  object.first_name ||= FFaker::NameFR.first_name
  object.last_name ||= "#{FFaker::NameFR.last_name}-#{Presenters::UserManagementRole.new(user: object).role}"
  object.accept_terms = true
  object.confirmed_at = (1..24).to_a.sample.hours.ago
  object.current_sign_in_at = (2..5).to_a.sample.days.ago
  object.last_sign_in_at = (12..16).to_a.sample.days.ago
  if object.student?
    object.gender ||= (['m'] * 4 + ['f'] * 4 + ['np']).sample
    if object.grade.present?
      type = object.grade == Grade.seconde ? :lycee : :college
      object.class_room ||= random_class_room(type: type)
      object.birth_date ||= (object.grade == Grade.troisieme ? 14 : 15).years.ago
    end
  end

  object
end

def call_method_with_metrics_tracking(methods)
  methods.each do |method_name|
    if method_name.is_a?(Symbol)
      ActiveSupport::Notifications.instrument "seed.#{method_name}" do
        send(method_name)
      end
    elsif method_name.is_a?(Array)
      real_method_name = method_name.shift
      ActiveSupport::Notifications.instrument "seed.#{real_method_name}" do
        send(real_method_name, *method_name)
      end
    end
  end
end

def a_parisian_lycee
  School.find_by_code_uai('0753268V') # school at Paris, school name : Lycée polyvalent Jean Lurçat.
end

def a_parisian_college
  School.find_by(code_uai: '0755030K') # name: "Collège Daniel Mayer"
end

ActiveSupport::Notifications.subscribe(/seed/) do |event|
  PrettyConsole.puts_in_cyan "#{event.name} done! #{event.duration}"
end

def prevent_sidekiq_to_run_job_after_seed_loaded
  Sidekiq.redis do |redis_con|
    redis_con.flushall
  end
end

if Rails.env == 'review' || Rails.env.development?
  Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].sort.each do |seed|
    PrettyConsole.puts_in_yellow "Loading #{seed}"
    load seed
  end

  School.update_all(updated_at: Time.now)
  prevent_sidekiq_to_run_job_after_seed_loaded
  Services::CounterManager.reset_internship_offer_counters
end

require 'pretty_console'

namespace :data_migrations do
  desc 'Dedup internship_applications sharing (user_id, internship_offer_id). Keep the most advanced state, delete the rest.'
  task dedup_internship_applications: :environment do |task|
    PrettyConsole.puts_with_white_background "Starting task : #{task.name}"

    app_order = InternshipApplication::ORDERED_STATES_INDEX
    agr_order = InternshipAgreement::ORDERED_STATES_INDEX
    # Among same-state applications, keep the one bearing the most advanced (kept) agreement.
    kept_agreement = ->(app) { InternshipAgreement.kept.find_by(internship_application_id: app.id) }
    sort_key = lambda do |app|
      agreement = kept_agreement.call(app)
      agr_rank = agreement ? (agr_order.index(agreement.aasm_state) || -1) : -1
      [-(app_order.index(app.aasm_state) || -1), -agr_rank, -app.updated_at.to_i]
    end
    label = ->(app) { "##{app.id}(#{app.aasm_state}/#{kept_agreement.call(app)&.aasm_state || 'none'})" }

    duplicate_keys = InternshipApplication
                     .group(:user_id, :internship_offer_id)
                     .having('COUNT(*) > 1')
                     .pluck(:user_id, :internship_offer_id)

    PrettyConsole.say_in_yellow "Found #{duplicate_keys.size} (user_id, internship_offer_id) couples with duplicates"
    total_deleted = 0

    duplicate_keys.each do |user_id, offer_id|
      apps = InternshipApplication.where(user_id: user_id, internship_offer_id: offer_id).to_a
      apps.sort_by!(&sort_key)
      keeper = apps.first
      to_delete = apps[1..]
      puts "user=#{user_id} offer=#{offer_id} keep=#{label.call(keeper)} delete=#{to_delete.map { |a| label.call(a) }.join(',')}"
      to_delete.each(&:destroy)
      total_deleted += to_delete.size
    end

    PrettyConsole.say_in_green "Task completed: #{total_deleted} duplicate applications deleted"
  end
end

require 'pretty_console'

namespace :data_migrations do
  desc 'Dedup internship_applications sharing (user_id, internship_offer_id). Keep the most advanced state, delete the rest.'
  task dedup_internship_applications: :environment do |task|
    PrettyConsole.puts_with_white_background "Starting task : #{task.name}"

    order = InternshipApplication::ORDERED_STATES_INDEX
    duplicate_keys = InternshipApplication
                     .group(:user_id, :internship_offer_id)
                     .having('COUNT(*) > 1')
                     .pluck(:user_id, :internship_offer_id)

    PrettyConsole.say_in_yellow "Found #{duplicate_keys.size} (user_id, internship_offer_id) couples with duplicates"
    total_deleted = 0

    duplicate_keys.each do |user_id, offer_id|
      apps = InternshipApplication.where(user_id: user_id, internship_offer_id: offer_id).to_a
      apps.sort_by! { |a| [-(order.index(a.aasm_state) || -1), -a.updated_at.to_i] }
      keeper = apps.first
      to_delete = apps[1..]
      puts "user=#{user_id} offer=#{offer_id} keep=##{keeper.id}(#{keeper.aasm_state}) delete=#{to_delete.map { |a| "##{a.id}(#{a.aasm_state})" }.join(',')}"
      to_delete.each(&:destroy)
      total_deleted += to_delete.size
    end

    PrettyConsole.say_in_green "Task completed: #{total_deleted} duplicate applications deleted"
  end
end

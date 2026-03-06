require 'pretty_console'

# to be duplicated/separated according to cases
# - schools as reserved schools (separated by school_type)
# - favorites (reassigned to new offers according to user grade)
# - internship applications (reassigned to new offers according to student grade)
# - users_internship_offers_histories (reassigned to new offers, plaing duplication)
# - weeks (restricted to the grade)

# aasm_state is duplicated as is and not changed
# max_candidates follow along
# unpublishing with cron job works as is : it does not publish whatever offer


namespace :retrofit do
  def ensure_doubling_offers_db_privileges!
    connection = ActiveRecord::Base.connection
    boolean = ActiveRecord::Type::Boolean.new

    current_user = connection.select_value('SELECT current_user')
    schema_usage = boolean.cast(
      connection.select_value("SELECT has_schema_privilege(current_user, 'public', 'USAGE')")
    )
    table_write = boolean.cast(
      connection.select_value("SELECT has_table_privilege(current_user, 'public.internship_offer_grades', 'INSERT,UPDATE,DELETE')")
    )
    sequence_name = connection.select_value(
      "SELECT pg_get_serial_sequence('public.internship_offer_grades', 'id')"
    )
    sequence_usage = sequence_name.blank? || boolean.cast(
      connection.select_value("SELECT has_sequence_privilege(current_user, '#{sequence_name}', 'USAGE,SELECT,UPDATE')")
    )

    return if schema_usage && table_write && sequence_usage

    missing = []
    missing << 'schema USAGE on public' unless schema_usage
    missing << 'table INSERT/UPDATE/DELETE on public.internship_offer_grades' unless table_write
    missing << "sequence USAGE/SELECT/UPDATE on #{sequence_name}" unless sequence_usage

    message = <<~MSG
      Missing DB privileges for retrofit:doubling_offers as role '#{current_user}'.
      Required: #{missing.join(', ')}.
      Ask DBA/admin to run:
        GRANT USAGE ON SCHEMA public TO #{current_user};
        GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.internship_offer_grades TO #{current_user};
        GRANT USAGE, SELECT, UPDATE ON SEQUENCE #{sequence_name || 'public.internship_offer_grades_id_seq'} TO #{current_user};
    MSG
    PrettyConsole.say_in_red(message)
    raise message
  end

  desc 'doubling offer when associated to several grades'
  task doubling_offers: :environment do |task|
    # en cas de problème de privilèges, voir
    # -- Existing objects
    # pseudo code :
    # BEGIN;
    # GRANT USAGE ON SCHEMA public TO #{ENV['CLEVER_REVIEW_DB_USER']};
    # GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO #{ENV['CLEVER_REVIEW_DB_USER']};
    # GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO #{ENV['CLEVER_REVIEW_DB_USER']};
    # COMMIT;

    # Note : the two scopes private_kept_for_doubling and public_kept_for_doubling are here to exclude
    # offers that cannot be split because of passed records defaults according to new
    # validation criteria.
    # These scopes should be withdrawn when all offers of the passed can be validated "as is"
    PrettyConsole.announce_task(task) do
      ensure_doubling_offers_db_privileges!
      InternshipOffer.kept
                     .seconde_and_troisieme
                     .merge(InternshipOffer.private_kept_for_doubling.or(InternshipOffer.public_kept_for_doubling))
                     .find_each do |offer|
        SplitOfferJob.perform_now(internship_offer_id: offer.id)
        print '-'
      end
    end
  end

  desc 'doubling offer test when associated to several grades'
  task doubling_offers_test: :environment do |task|
    PrettyConsole.announce_task(task) do
      counter = 0
      total_offer_counted = 0
      InternshipOffer.kept
                     .seconde_and_troisieme
                     .merge(InternshipOffer.private_kept_for_doubling.or(InternshipOffer.public_kept_for_doubling))
                     .find_each do |offer|
        total_offer_counted += 1
        weeks_seconde = offer.weeks.select { |week| week.number >= 24 && week.number <= 27 }
        weeks_troisieme_quatrieme = offer.weeks.to_a - weeks_seconde.to_a
        if weeks_seconde.empty? || weeks_troisieme_quatrieme.empty?
          counter += 1
        end
      end
      PrettyConsole.say_in_green("Tested #{counter} offers cannot be split out of #{total_offer_counted} offers counted")
    end
  end
end

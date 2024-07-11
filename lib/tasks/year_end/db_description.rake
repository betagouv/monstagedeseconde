require 'pretty_console'

namespace :year_end do
  desc 'describe column size after exploitation'
  task :column_size, [] => :environment do |args|
    tables = [InternshipOffer,
              Organisation,
              InternshipOfferInfo,
              HostingInfo,
              PracticalInfo,
              Tutor,
              InternshipApplication,
              InternshipAgreement,
              User,
              Identity,
              AcademyRegion,
              Academy,
              ClassRoom,
              Craft,
              Department,
              DetailedCraft,
              Group,
              InternshipOfferArea,
              Invitation,
              Operator,
              Organisation,
              PracticalInfo,
              School,
              Sector,
              TaskRegister,
              TeamMemberInvitation,
              Tutor,
              UrlShrinker]
    table_list = tables.map do |table| table.name end.join(', ')
    PrettyConsole.announce_task("Describing column size for #{table_list}") do
      tables.each do |table|
        PrettyConsole.puts_in_green "Table: #{table.name}"
        puts '-------------------'
        table.column_names.each do |column_name|
          next unless table.columns_hash[column_name].type == :string

          limit1 = table.pluck(column_name.to_sym)
                        .map(&:to_s)
                        .sort_by(&:size)
                        .last&.size || 0
          PrettyConsole.print_in_yellow "#{column_name} ; #{limit1};"
          puts ''
        end
        puts '-------------------'
        puts ' '
      end

      other_fields = [
        [InternshipApplication, %i[ rich_text_motivation
                                    rich_text_rejected_message
                                    rich_text_canceled_by_employer_message]],
                                    # rich_text_resume_other
                                    # rich_text_resume_languages
        [InternshipOfferInfo, [:description_rich_text]],
        [InternshipAgreement, %i[ activity_scope_rich_text
                                  activity_preparation_rich_text
                                  activity_learnings_rich_text
                                  activity_rating_rich_text
                                  skills_observe_rich_text
                                  skills_communicate_rich_text
                                  skills_understand_rich_text
                                  skills_motivation_rich_text]],
                                  # legal_terms_rich_text
        [InternshipOffer, [:description_rich_text]],
        [School, [:agreement_conditions_rich_text]],
      ]
        #
        # resume_educational_background_rich_text
      other_fields.each do |model, fields|
        PrettyConsole.puts_in_green "Table: #{model.name}"
        puts '-------------------'
        fields.each do |field|
          limit1 = model.all
                        .map { |record| record.send(field)}
                        .compact
                        .map(&:to_plain_text)
                        .sort_by(&:size)
                        .last&.size || 0
          PrettyConsole.print_in_yellow "#{field.to_s} ; #{limit1};"
          puts ''
        end
        puts '-------------------'
        puts ' '
      end
    end
  end
end
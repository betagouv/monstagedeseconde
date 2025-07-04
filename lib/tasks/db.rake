namespace :db do
  namespace :structure do
    # heroku hack for review apps
    task dump: [:environment, :load_config] do
      rewrite_comment_on_extension
    end

    # can't comment on extension public extension [heroku]
    def rewrite_comment_on_extension
      filename = ENV["SCHEMA"] || File.join(ActiveRecord::Tasks::DatabaseTasks.db_dir, "structure.sql")

      sql = File.read(filename)
                .each_line
                .grep_v(/\ACOMMENT ON EXTENSION.+/) # see: https://www.thinbug.com/q/44168957
                .join

      File.write(filename, sql)
    end
  end
  namespace :seed do
    desc 'create weeks fixture file'
    task weeks: :environment do
      weeks = Week.all
      File.open(Rails.root.join('test/fixtures/weeks_test.yml'), 'w') do |f|
        weeks.each do |week|
          f.write("week_#{week.year}_#{week.number}:\n")
          f.write("  number: #{week.number}\n")
          f.write("  year: #{week.year}\n")
          f.write("  id: #{week.id}\n")
          f.write("\n")
        end
      end
    end
  end
end

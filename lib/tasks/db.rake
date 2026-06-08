namespace :db do
  # heroku hack: strip `COMMENT ON EXTENSION` lines from structure.sql after dump,
  # because the Heroku Postgres user is not the extension owner and the load fails.
  # see: https://www.thinbug.com/q/44168957
  task :strip_extension_comments do
    filename = ENV["SCHEMA"] || File.join(ActiveRecord::Tasks::DatabaseTasks.db_dir, "structure.sql")
    next unless File.exist?(filename)

    sql = File.read(filename)
              .each_line
              .grep_v(/\ACOMMENT ON EXTENSION.+/)
              .join

    File.write(filename, sql)
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

# Run the strip after any dump task that writes structure.sql. Rails 8 routes
# schema:format=:sql dumps through `db:schema:dump` (and per-db variants);
# `db:structure:dump` is kept for back-compat.
%w[db:schema:dump db:structure:dump].each do |task_name|
  Rake::Task[task_name].enhance { Rake::Task["db:strip_extension_comments"].invoke } if Rake::Task.task_defined?(task_name)
end

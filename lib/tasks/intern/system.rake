require 'pretty_console'

namespace :sys do
  def timestamp
    DateTime.now.to_s.gsub(/:/, '_').split(/\+/).first
  end

  def db_file_name
    "storage/tmp/#{timestamp}_1E1S_prod.dump"
  end

  def db_file_name_sql
    "storage/tmp/#{timestamp}_1E1S_prod.sql"
  end

  def reset_file_name
    'storage/tmp/reset_1E1S_prod_copy.sql'
  end

  desc "test database to check if it is production's copy"
  task :is_prod, [] => :environment do
    file = Rails.root.join('config/database.yml')
    text = File.read(file)
    is_in_prod = !text.match?(/# url: <%= ENV.fetch\('CLEVER_PRODUCTION_COPY_CONNEXION_URI'\)/)
    if is_in_prod
      PrettyConsole.puts_in_red 'Database is a copy of production'
    else
      PrettyConsole.puts_in_green 'Database is local'
    end
  end

  desc 'uncomment url in database.yml to switch database from local to production copy'
  task :db_prod, [] => :environment do
    file = Rails.root.join('config/database.yml')
    text = File.read(file)
    text = text.gsub(/#(?: #)*/, '#')
    new_contents = text.gsub(/# url: <%= ENV.fetch\('CLEVER_PRODUCTION_COPY_CONNEXION_URI'\)/,
                             "url: <%= ENV.fetch('CLEVER_PRODUCTION_COPY_CONNEXION_URI')")
    File.open(file, 'w') { |f| f.puts new_contents }
  end

  desc 'comment url in database.yml to switch database from production copy to local'
  task :db_local, [] => :environment do
    file = Rails.root.join('config/database.yml')
    text = File.read(file)
    new_contents = text.gsub(/url: <%= ENV.fetch\('CLEVER_PRODUCTION_COPY_CONNEXION_URI'\)/,
                             "# url: <%= ENV.fetch('CLEVER_PRODUCTION_COPY_CONNEXION_URI')")
    File.open(file, 'w') { |f| f.puts new_contents }
    puts 'Database is now local'
  end

  desc 'download a production database copy to filesystem'
  task :dl_prod, [] => :environment do
    if File.exist?(db_file_name)
      PrettyConsole.puts_in_cyan 'File already exists'
    else
      PrettyConsole.announce_task 'Downloading production database' do
        system('pg_dump -c --clean --if-exists -Fc --encoding=UTF-8 --no-owner --no-password  ' \
        "-d #{ENV['PRODUCTION_DATABASE_URI']} > #{db_file_name}")
      end
    end
  end

  desc 'download a production database copy to filesystem with sql format'
  task :dl_prod_sql, [] => :environment do
    if File.exist?(db_file_name_sql)
      PrettyConsole.puts_in_cyan 'File already exists'
    else
      PrettyConsole.announce_task 'Downloading production database' do
        system('pg_dump -c --clean --if-exists -Fp --encoding=UTF-8 --no-owner --no-password  ' \
        "-d #{ENV['PRODUCTION_DATABASE_URI']} > #{db_file_name_sql}")
      end
    end
  end

  desc 'uplaod a local production database copy to CleverCloud'
  task :upl_prod, [] => :environment do
    PrettyConsole.announce_task 'Downloading production database' do
      system("pg_restore -h #{ENV['CLEVER_PRODUCTION_COPY_HOST']} " \
              "-p #{ENV['CLEVER_PRODUCTION_COPY_DB_PORT']} " \
              "-U #{ENV['CLEVER_PRODUCTION_COPY_DB_USER']} " \
              "-f #{db_file_name}")
    end
  end

  desc 'uplaod a local production database copy to CleverCloud with sql format'
  task :upl_prod_sql, [] => :environment do
    PrettyConsole.announce_task 'Downloading production database' do
      system("PGPASSWORD=#{ENV['CLEVER_PRODUCTION_COPY_DB_PASSWORD']} psql " \
              "-h #{ENV['CLEVER_PRODUCTION_COPY_HOST']} " \
              "-p #{ENV['CLEVER_PRODUCTION_COPY_DB_PORT']} " \
              "-U #{ENV['CLEVER_PRODUCTION_COPY_DB_USER']} " \
              "-d #{ENV['CLEVER_PRODUCTION_COPY_DB_NAME']} " \
              "-d #{ENV['CLEVER_PRODUCTION_COPY_DB_NAME']} " \
              "-f #{db_file_name_sql}")
    end
  end

  # desc 'uplaod a local production database copy to CleverCloud'
  # task :reset_copy, [] => :environment do
  #   PrettyConsole.announce_task 'Downloading production database' do
  #     system("psql -h #{ENV['CLEVER_PRODUCTION_COPY_HOST']} " \
  #             "-p #{ENV['CLEVER_PRODUCTION_COPY_DB_PORT']} " \
  #             "-U #{ENV['CLEVER_PRODUCTION_COPY_DB_USER']} " \
  #             "-d #{ENV['CLEVER_PRODUCTION_COPY_DB_NAME']} " \
  #             "-f #{reset_file_name}")
  #   end
  # end
  #

  desc 'kill all sidekiq processes from their task name on Scheduled queue'
  task :kill_scheduled_sidekiq, [:task_name] => :environment do |t, args|
    PrettyConsole.announce_task "Killing sidekiq processes with #{args.task_name}" do
      counter = 0
      not_treated = 0
      Sidekiq::ScheduledSet.new.each do |job|
        puts job.args.first
        if job.args.first['job_class'] == args.task_name
          counter += 1
          job.delete
          print '.'
          PrettyConsole.puts_in_green " #{counter} |" if counter % 100 == 0
        else
          not_treated += 1
          print ' 100 |' if not_treated % 100 == 0
        end
      end
      PrettyConsole.say_in_yellow "#{counter} jobs deleted | #{not_treated} jobs not treated"
    end
  end

  desc 'kill all sidekiq processes from their task name on Retries queue'
  task :kill_retries_sidekiq, [:task_name] => :environment do |t, args|
    PrettyConsole.announce_task "Killing sidekiq processes with #{args.task_name}" do
      counter = 0
      not_treated = 0
      Sidekiq::RetrySet.new.each do |job|
        puts job.args.first
        if job.args.first['job_class'] == args.task_name
          counter += 1
          job.delete
          print '.'
          PrettyConsole.puts_in_green " #{counter} |" if counter % 100 == 0
        else
          not_treated += 1
          print ' 100 |' if not_treated % 100 == 0
        end
      end
      PrettyConsole.say_in_yellow "#{counter} jobs deleted | #{not_treated} jobs not treated"
    end
  end

  desc 'download an upload a sql copy of the production database'
  task :dl_upl_prod_sql, [] => :environment do
    if Rails.env.staging? || Rails.env.development?
      chosen_db_name = db_file_name_sql
      PrettyConsole.announce_task 'Downloading production database' do
        system('pg_dump -c --clean --if-exists -Fp --encoding=UTF-8 --no-owner --no-password  ' \
        "-d #{ENV['PRODUCTION_DATABASE_URI']} > #{chosen_db_name}")
      end

      PrettyConsole.announce_task 'Downloading production database' do
        system("PGPASSWORD=#{ENV['CLEVER_PRODUCTION_COPY_DB_PASSWORD']} psql " \
                "-h #{ENV['CLEVER_PRODUCTION_COPY_HOST']} " \
                "-p #{ENV['CLEVER_PRODUCTION_COPY_DB_PORT']} " \
                "-U #{ENV['CLEVER_PRODUCTION_COPY_DB_USER']} " \
                "-d #{ENV['CLEVER_PRODUCTION_COPY_DB_NAME']} " \
                "-d #{ENV['CLEVER_PRODUCTION_COPY_DB_NAME']} " \
                "-f #{chosen_db_name}")
      end
    else
      PrettyConsole.puts_in_red 'You cannot run this task only wiht dev or staging environment'
    end
  end
end

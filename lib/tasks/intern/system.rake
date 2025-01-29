require 'pretty_console'

namespace :sys do

  def db_file_name
    "storage/tmp/#{Date.today}_1E1S_prod.dump"
  end

  def reset_file_name
    "storage/tmp/reset_1E1S_prod_copy.sql"
  end

  desc "test database to check if it is production's copy"
  task :is_prod , [] => :environment do
    file = Rails.root.join('config/database.yml')
    text = File.read(file)
    is_in_prod = !text.match?(/# url: \<\%\= ENV.fetch\(\'CLEVER_PRODUCTION_COPY_CONNEXION_URI\'\)/)
    if is_in_prod
      PrettyConsole.puts_in_red 'Database is in production'
    else
      PrettyConsole.puts_in_green 'Database is local'
    end
  end

  desc 'uncomment url in database.yml to switch database from local to production copy'
  task :db_prod , [] => :environment do
    file = Rails.root.join('config/database.yml')
    text = File.read(file)
    new_contents = text.gsub(/# url: \<\%\= ENV.fetch\(\'CLEVER_PRODUCTION_COPY_CONNEXION_URI\'\)/ , "url: <%= ENV.fetch('CLEVER_PRODUCTION_COPY_CONNEXION_URI')")
    File.open(file, 'w') { |f| f.puts new_contents }
  end

  desc 'comment url in database.yml to switch database from production copy to local'
  task :db_local , [] => :environment do
      file = Rails.root.join('config/database.yml')
      text = File.read(file)
      new_contents = text.gsub(/url: \<\%\= ENV.fetch\(\'CLEVER_PRODUCTION_COPY_CONNEXION_URI\'\)/ , "# url: <%= ENV.fetch('CLEVER_PRODUCTION_COPY_CONNEXION_URI')")
      File.open(file, 'w') { |f| f.puts new_contents }
      puts 'Database is now local'
  end

  desc 'download a production database copy to filesystem'
  task :dl_prod, [] => :environment do
    if File.exist?(db_file_name)
      PrettyConsole.puts_in_cyan 'File already exists'
    else
      PrettyConsole.announce_task 'Downloading production database' do
        system("pg_dump -c --clean --if-exists -Fc --encoding=UTF-8 --no-owner --no-password  " \
        "-d #{ENV['PRODUCTION_DATABASE_URI']} > #{db_file_name}")
      end
    end
  end

  desc 'uplaod a local production database copy to CleverCloud'
  task :upl_prod, [] => :environment do
    PrettyConsole.announce_task 'Downloading production database' do
      system("psql -c -h #{ENV['CLEVER_PRODUCTION_COPY_HOST']} " \
              "-p #{ENV['CLEVER_PRODUCTION_COPY_DB_PORT']} " \
              "-U #{ENV['CLEVER_PRODUCTION_COPY_DB_USER']} " \
              "-d #{ENV['CLEVER_PRODUCTION_COPY_DB_NAME']} " \
              "-f #{db_file_name}")
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
end
begin
  require 'rswag/specs/rake_task'

  RSpec::Core::RakeTask.new(:rswag_specs) do |t|
    t.pattern = 'spec/requests/**/*_spec.rb'
  end

  desc 'Generate Swagger documentation'
  task 'rswag:specs:swaggerize' => :environment do
    # Only run rswag specs, not all specs
    ENV['PATTERN'] = 'spec/requests/**/*_spec.rb'
    Rake::Task['rswag_specs'].invoke
  end

rescue LoadError
  # rswag gems not available, skip these tasks
  puts "rswag gems not available. Skipping rswag rake tasks."

  desc 'Generate Swagger documentation (rswag not available)'
  task 'rswag:specs:swaggerize' do
    puts "rswag gem not installed. Install with: gem install rswag"
  end
end
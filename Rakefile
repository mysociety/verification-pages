# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be
# available to Rake.

require_relative 'config/application'
require 'rubocop/rake_task'

Rails.application.load_tasks
RuboCop::RakeTask.new

namespace :verification_page do
  desc 'Load suggestion statements from suggestions store'
  task :load, %i[page_title] => %i[environment] do |_, args|
    abort('Require page title argument') if args.page_title.blank?
    statements = LoadStatements.run(args.page_title)
    puts "#{statements.count} Statements loaded"
  end
end

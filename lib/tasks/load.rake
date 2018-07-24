# frozen_string_literal: true

namespace :verification_page do
  desc 'Load statements from suggestions store'
  task :load, %i[page_title] => %i[environment] do |_, args|
    abort('Require page title argument') if args.page_title.blank?
    statements = LoadStatements.run(args.page_title)
    puts "#{statements.count} Statements loaded"
  end

  namespace :load do
    desc 'Load statements for all pages from suggestion store'
    task all: :environment do
      Page.all.each do |page|
        statements = LoadStatements.run(page.title)
        puts "#{statements.count} Statements loaded for #{page.title}"
      end
    end
  end
end

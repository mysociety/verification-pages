# frozen_string_literal: true

namespace :verification_page do
  desc 'Generate verification page for the page_title given'
  task :generate, %i[page_title] => %i[environment] do |_, args|
    abort('Require page title argument') if args.page_title.blank?
    puts GenerateVerificationPage.run(args.page_title)
  end

  namespace :generate do
    desc 'Create or update all verification pages'
    task all: :environment do
      Page.find_each do |page|
        puts GenerateVerificationPage.run(page.title)
      end
    end
  end

  desc 'Update verification page for the page_title given'
  task :update, %i[page_title] => %i[environment] do |_, args|
    begin
      abort('Require page title argument') if args.page_title.blank?
      UpdateVerificationPage.run(args.page_title)
      puts 'Verification page now visible at: ' \
        "https://#{ENV['WIKIDATA_SITE']}/wiki/#{args.page_title}"
    rescue MediawikiApi::EditError => ex
      puts ex.response.inspect
    end
  end

  namespace :update do
    desc 'Update verification page templates'
    task templates: :environment do
      UpdateVerificationTemplates.run(
        "User:#{ENV.fetch('WIKIDATA_USERNAME')}/verification"
      )
    end

    desc 'Update verification page javascript'
    task javascript: :environment do
      UpdateVerificationJavascript.run(
        "User:#{ENV.fetch('WIKIDATA_USERNAME')}/verification.js"
      )
    end
  end
end

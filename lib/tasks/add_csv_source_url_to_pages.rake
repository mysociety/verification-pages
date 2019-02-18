# frozen_string_literal: true

desc 'Add CSV source URL to existing pages'
task add_csv_source_url_to_pages: :environment do
  Page.transaction do
    Page.find_each do |page|
      country = SuggestionsStore::Country.new(page.country_code)
      url = country.export_position_url(page.position_held_item, format: 'csv')
      page.csv_source_url = url
      page.save!
    end
  end
end

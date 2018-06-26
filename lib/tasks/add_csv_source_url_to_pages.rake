desc 'Add CSV source URL to existing pages'
task add_csv_source_url_to_pages: :environment do
  Page.transaction do
    Page.find_each do |page|
      uri = URI(ENV.fetch('SUGGESTIONS_STORE_URL'))
      uri.path = "/export/#{page.country.code}/#{page.position_held_item}.csv"
      page.csv_source_url = uri.to_s
      page.save!
    end
  end
end

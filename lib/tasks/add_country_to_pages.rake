# frozen_string_literal: true

desc 'Add country_id to existing pages'
task add_country_to_pages: :environment do
  Page.all.each do |page|
    match = %r{^User:Graemebp/verification/(?<country_code>\w{2})}.match(page.title)
    country = Country.find_by!(code: match[:country_code])
    page.country_id = country.id
    page.save!
  end
end

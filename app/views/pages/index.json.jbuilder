# frozen_string_literal: true

json.pages @pages do |page|
  json.call(page, :id, :title, :position_held_item, :parliamentary_term_item,
            :reference_url, :reference_url_title, :reference_url_language,
            :executive_position, :csv_source_url, :created_at, :updated_at,
            :from_suggestions_store?)

  json.country(name: page.country_name)
end

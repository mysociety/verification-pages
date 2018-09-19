# frozen_string_literal: true

json.pages(
  @pages,
  :id, :title, :position_held_item, :parliamentary_term_item,
  :reference_url,
  :executive_position,
  :csv_source_url,
  :country_id,
  :reference_url_title,
  :reference_url_language,
  :created_at, :updated_at,
  :from_suggestions_store?,
  :country
)

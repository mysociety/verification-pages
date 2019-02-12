# frozen_string_literal: true

json.extract! country, :id, :name, :code, :wikidata_id, :created_at, :updated_at
json.url country_url(country, format: :json)

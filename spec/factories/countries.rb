# frozen_string_literal: true

FactoryBot.define do
  factory :country do
    name { 'Canada' }
    code { 'ca' }
    wikidata_id { 'Q16' }
  end
end

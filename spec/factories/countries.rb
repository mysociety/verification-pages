# frozen_string_literal: true

FactoryBot.define do
  factory :country do
    name { 'Canada' }
    code { 'ca' }
    description_en { 'Canadian politician' }
    label_lang { 'en' }
    wikidata_id { 'Q16' }
  end
end

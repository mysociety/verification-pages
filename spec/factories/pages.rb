# frozen_string_literal: true

FactoryBot.define do
  sequence :title do |n|
    "Test page #{n}"
  end
  factory :page do
    title
    position_held_item { 'Q1' }
    reference_url { 'http://example.com' }
    csv_source_url { 'https://example.com/export.csv' }
    country_item { 'Q16' }
    country_code { 'ca' }
  end
end

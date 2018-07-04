FactoryBot.define do
  factory :page do
    title 'Test page'
    position_held_item 'Q1'
    reference_url 'http://example.com'
    csv_source_url 'https://example.com/export.csv'
    country
  end
end

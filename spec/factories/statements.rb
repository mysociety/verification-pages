# frozen_string_literal: true

FactoryBot.define do
  factory :statement do
    page
    sequence(:transaction_id) { |n| 123 + n }
  end

  factory :statement_with_names, class: Statement do
    person_name { 'Person' }
    electoral_district_name { 'District' }
  end
end

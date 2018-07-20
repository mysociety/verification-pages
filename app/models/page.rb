# frozen_string_literal: true

# Verification page object
class Page < ApplicationRecord
  has_many :statements, dependent: :destroy
  belongs_to :country

  validates :title, presence: true, uniqueness: true
  validates :position_held_item, presence: true
  validates :reference_url, presence: true
  validates :csv_source_url, presence: true
end

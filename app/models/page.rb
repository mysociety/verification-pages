# frozen_string_literal: true

# Verification page object
class Page < ApplicationRecord
  validates :title, presence: true
  validates :position_held_item, presence: true
  validates :parliamentary_term_item, presence: true
  validates :reference_url, presence: true
end

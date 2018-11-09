# frozen_string_literal: true

# Verification page object
class Page < ApplicationRecord
  include TransactionID

  has_many :statements, dependent: :destroy
  belongs_to :country

  validates :title, presence: true, uniqueness: true
  validates :position_held_item, presence: true
  validates :reference_url, length: { maximum: 2000 }
  validates :csv_source_url, presence: true

  before_validation :set_position_held_name, if: :position_held_item_changed?
  before_validation :set_parliamentary_term_name, if: :parliamentary_term_item_changed?

  def from_suggestions_store?
    URI.parse(csv_source_url).host == URI.parse(SuggestionsStore::Request::URL).host
  end

  private

  def set_position_held_name
    self.position_held_name = labels[position_held_item]
  end

  def set_parliamentary_term_name
    self.parliamentary_term_name = labels[parliamentary_term_item]
  end

  def item_data
    @item_data ||= RetrieveItems.run(position_held_item, parliamentary_term_item)
  end
end

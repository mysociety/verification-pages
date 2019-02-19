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

  def new_item_description_en
    super || country&.description_en
  end

  def new_item_label_language
    super || country&.label_lang
  end

  private

  def set_position_held_name
    self.position_held_name = item_data[position_held_item]&.label
  end

  def set_parliamentary_term_name
    self.parliamentary_term_name = item_data[parliamentary_term_item]&.label
  end

  def item_data
    @item_data ||= RetrieveItems.run(position_held_item, parliamentary_term_item)
  end
end

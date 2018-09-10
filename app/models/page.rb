# frozen_string_literal: true

# Verification page object
class Page < ApplicationRecord
  has_many :statements, dependent: :destroy
  belongs_to :country

  validates :title, presence: true, uniqueness: true
  validates :position_held_item, presence: true
  validates :reference_url, length: { maximum: 2000 }
  validates :csv_source_url, presence: true

  before_validation :set_position_held_name, if: :position_held_item_changed?
  before_validation :set_parliamentary_term_name, if: :parliamentary_term_item_changed?

  def from_suggestions_store?
    /^#{Regexp.escape(ENV.fetch('SUGGESTIONS_STORE_URL'))}/.match?(csv_source_url)
  end

  private

  def set_position_held_name
    self.position_held_name = page_data&.position_name
  end

  def set_parliamentary_term_name
    self.parliamentary_term_name = page_data&.term_name
  end

  def page_data
    @page_data ||= RetrievePageData.run(position_held_item, parliamentary_term_item)
  end
end

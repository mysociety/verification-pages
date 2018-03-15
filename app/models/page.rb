# frozen_string_literal: true

# Verification page object
class Page < ApplicationRecord
  validates :title, presence: true
  validates :position_held_item, presence: true
  validates :parliamentary_term_item, uniqueness: { allow_blank: true }
  validates :reference_url, presence: true

  def statements
    # TODO: confirm how to identify which statements are associated with a page
    # probably not going to be parliamentary_term as this won't be in the
    # suggestion store
    Statement.where(parliamentary_term_item: parliamentary_term_item)
  end
end

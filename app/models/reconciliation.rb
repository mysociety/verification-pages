# frozen_string_literal: true

# Reconciliation result object
class Reconciliation < ApplicationRecord
  belongs_to :statement

  validates :item, presence: true

  default_scope -> { order(updated_at: :asc) }

  after_commit :update_statement

  private

  def update_statement
    statement.update_attributes(person_item: item)
  end
end

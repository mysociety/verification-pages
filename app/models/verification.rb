# frozen_string_literal: true

# Verification result object
class Verification < ApplicationRecord
  belongs_to :statement

  validates :reference_url, presence: true

  default_scope -> { order(updated_at: :asc) }

  after_commit :send_to_suggestions_store

  private

  def send_to_suggestions_store
    UpdateStatementVerification.run(self) if statement.from_suggestions_store?
  end
end

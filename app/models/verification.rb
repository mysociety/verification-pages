# frozen_string_literal: true

# Verification result object
class Verification < ApplicationRecord
  belongs_to :statement

  default_scope -> { order(updated_at: :asc) }

  after_commit :send_to_suggestions_store

  private

  def send_to_suggestions_store
    UpdateStatementVerification.run(self)
  end
end

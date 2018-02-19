# frozen_string_literal: true

# Verification result object
class Verification < ApplicationRecord
  belongs_to :statement

  default_scope -> { order(updated_at: :asc) }
end

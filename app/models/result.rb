# frozen_string_literal: true

# Verification result object
class Result < ApplicationRecord
  belongs_to :statement

  enum status: %i[undecided yes no]
end

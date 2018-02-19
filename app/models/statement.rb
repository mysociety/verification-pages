# frozen_string_literal: true

# Statement for verification object
class Statement < ApplicationRecord
  has_many :verifications, dependent: :destroy

  def latest_reconciliation; end

  def latest_verification
    verifications.last
  end

  def create_verification!(params)
    verifications.create!(params)
  end
end

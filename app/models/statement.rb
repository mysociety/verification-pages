# frozen_string_literal: true

# Statement for verification object
class Statement < ApplicationRecord
  has_many :verifications, dependent: :destroy
  has_many :reconciliations, dependent: :destroy

  validates :transaction_id, presence: true, uniqueness: true

  def page
    Page.find_by(parliamentary_term_item: parliamentary_term_item)
  end

  def latest_verification
    verifications.last
  end

  def latest_reconciliation
    reconciliations.last
  end

  def force_type
    Rails.cache.read(force_type_key)
  end

  def force_type!(type)
    # This will generate cached item with key
    # "force_type/statements/<id>-<updated_at>" so expire automatically if the
    # statement is updated
    Rails.cache.write(force_type_key, type, expires_in: 5.minutes)
  end

  private

  def force_type_key
    [:force_type, self]
  end
end

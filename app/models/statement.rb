# frozen_string_literal: true

# Statement for verification object
class Statement < ApplicationRecord
  scope :original, -> { where(duplicate: false) }

  belongs_to :page
  has_many :verifications, dependent: :destroy
  has_many :reconciliations, dependent: :destroy

  validates :transaction_id, presence: true, uniqueness: true

  before_create :detect_duplicate_statements, :retrieve_wikidata_id
  after_create :verify_duplicate!, if: :duplicate?

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

  def detect_duplicate_statements
    self.duplicate ||= duplicate_statements.present?
  end

  def duplicate_statements
    Statement.where(
      person_name: person_name,
      parliamentary_term_item: parliamentary_term_item,
      electoral_district_name: electoral_district_name,
      electoral_district_item: electoral_district_item,
      fb_identifier: fb_identifier
    ).where.not(id: id).order(created_at: :asc)
  end

  def verify_duplicate!
    duplicate_verification = duplicate_statements.last.latest_verification
    return unless duplicate_verification

    verifications.create!(
      user: duplicate_verification.user,
      status: duplicate_verification.status
    )
  end

  def retrieve_wikidata_id
    self.person_item ||= store.wikidata_id
  end

  def store
    IDMappingStore.new(wikidata_id: person_item, facebook_id: fb_identifier)
  end
end

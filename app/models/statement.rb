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

  delegate :parliamentary_term_item, :parliamentary_term_name, to: :page

  def latest_verification
    verifications.last
  end

  def latest_reconciliation
    reconciliations.last
  end

  def record_actioned!(classifier_version = nil)
    self.actioned_at = Time.zone.now
    self.classifier_version = classifier_version.sub(/^v/, '') if classifier_version
    save!
  end

  def report_error!(error_message)
    self.error_reported = error_message
    self.reported_at = Time.zone.now
    save!
  end

  def clear_error!
    self.error_reported = nil
    self.reported_at = nil
    save!
  end

  def self_and_duplicate_statements
    Statement.where(
      page:                     page,
      person_name:              person_name,
      electoral_district_name:  electoral_district_name,
      electoral_district_item:  electoral_district_item,
      parliamentary_group_item: parliamentary_group_item,
      parliamentary_group_name: parliamentary_group_name,
      position_start:           position_start,
      position_end:             position_end,
      fb_identifier:            fb_identifier,
      removed_from_source:      false
    )
  end

  def duplicate_statements
    self_and_duplicate_statements.where.not(id: id).order(created_at: :asc)
  end

  delegate :from_suggestions_store?, to: :page

  private

  def detect_duplicate_statements
    self.duplicate ||= duplicate_statements.present?
  end

  def verify_duplicate!
    duplicate_verification = duplicate_statements.last.latest_verification
    return unless duplicate_verification

    verifications.create!(
      user:          duplicate_verification.user,
      status:        duplicate_verification.status,
      reference_url: duplicate_verification.reference_url
    )
  end

  def retrieve_wikidata_id
    self.person_item ||= store.wikidata_id
  end

  def store
    IDMappingStore.new(wikidata_id: person_item, facebook_id: fb_identifier)
  end
end

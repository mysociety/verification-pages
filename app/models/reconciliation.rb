# frozen_string_literal: true

# Reconciliation result object
class Reconciliation < ApplicationRecord
  belongs_to :statement

  validates :item, :resource_type, presence: true

  default_scope -> { order(updated_at: :asc) }

  after_commit :update_statement, :create_equivalence_claim

  private

  def update_statement
    case resource_type
    when 'person'
      statement.update_attributes(person_item: item)
    when 'party'
      statement.update_attributes(parliamentary_group_item: item)
    when 'district'
      statement.update_attributes(electoral_district_item: item)
    end
  end

  def create_equivalence_claim
    return if resource_type != 'person' || !item_changed?
    store.create_equivalence_claim("Added FB ID for #{statement.person_name}")
  end

  def store
    IDMappingStore.new(wikidata_id: item, facebook_id: statement.fb_identifier)
  end
end

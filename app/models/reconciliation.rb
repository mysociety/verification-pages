# frozen_string_literal: true

# Reconciliation result object
class Reconciliation < ApplicationRecord
  belongs_to :statement

  enum update_type: %i[single also_matching_unreconciled also_matching]

  validates :item, :resource_type, presence: true

  default_scope -> { order(updated_at: :asc) }

  after_commit :update_statement, :create_equivalence_claim

  def possibly_updated_statements
    return Statement.where(id: statement.id) if single
    Statement.where(id: statement.id).or(Statement.where(where_condition_matching_name))
  end

  private

  def update_statement
    statement.update(item_attr => item)
    return if single
    other_statements_for_update.update(item_attr => item)
  end

  def single
    resource_type == 'person' || update_type == 'single'
  end

  def other_statements_for_update
    Statement.where(where_condition_for_update).where.not(id: statement.id)
  end

  def name_attr
    resource_attrs[:name]
  end

  def item_attr
    resource_attrs[:item]
  end

  def resource_attrs
    {
      'person'   => { item: :person_item,              name: :person_name },
      'party'    => { item: :parliamentary_group_item, name: :parliamentary_group_name },
      'district' => { item: :electoral_district_item,  name: :electoral_district_name },
    }[resource_type]
  end

  def where_condition_matching_name
    {
      :page     => statement.page,
      name_attr => statement.public_send(name_attr),
    }
  end

  def where_condition_for_update
    where_condition = where_condition_matching_name.clone
    where_condition[item_attr] = nil if update_type == 'also_matching_unreconciled'
    where_condition
  end

  def create_equivalence_claim
    return if resource_type != 'person' || !item_changed?
    store.create_equivalence_claim("Added FB ID for #{statement.person_name}")
  end

  def store
    IDMappingStore.new(wikidata_id: item, facebook_id: statement.fb_identifier)
  end
end

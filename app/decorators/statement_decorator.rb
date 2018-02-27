# frozen_string_literal: true

# Decorator with merges statements with up-to-date position held data
class StatementDecorator < SimpleDelegator
  attr_reader :data
  attr_accessor :type

  def initialize(statement, position_held_data)
    @data = position_held_data
    statement.person_revision ||= data&.revision
    super(statement)
  end

  def done?
    data&.person && person_item == data&.person &&
      data&.district && electoral_district_item == data&.district &&
      data&.group && parliamentary_group_item == data&.group &&
      data&.position && statement_uuid == data&.position &&
      data&.term && parliamentary_term_item == data&.term
  end

  def started_before_term?
    data&.start_date && data&.start_of_term &&
      Date.parse(data.start_date) < Date.parse(data.start_of_term) - 1.day
  end

  def qualifiers_contradicting?
    data&.district && electoral_district_item != data&.district ||
      data&.group && parliamentary_group_item != data&.group
  end

  def unverifiable?
    latest_verification && latest_verification.status == false
  end

  def verified?
    latest_verification && latest_verification.status == true
  end

  def reconciled?
    person_item.present?
  end
end

# frozen_string_literal: true

# Decorator with merges statements with up-to-date position held data
class StatementDecorator < SimpleDelegator
  attr_reader :data

  def initialize(statement, position_held_data)
    @data = position_held_data

    statement.person_item ||= data&.person
    statement.person_revision ||= data&.revision
    statement.statement_uuid ||= data&.position
    statement.parliamentary_group_item ||= data&.group
    statement.electoral_district_item ||= data&.district
    statement.parliamentary_term_item ||= data&.term

    super(statement)
  end

  def qualifiers_contradicting?
    electoral_district_item != data.district ||
      parliamentary_group_item != data.group
  end

  def term_invalid?
    parliamentary_term_item != data.term
  end

  def result_negative?
    latest_result && latest_result.status == 'no'
  end

  def result_positive?
    latest_result && latest_result.status == 'yes'
  end

  def started_before_term?
    data.start_date && data.start_of_term &&
      Date.parse(data.start_date) < Date.parse(data.start_of_term) - 1.day
  end
end

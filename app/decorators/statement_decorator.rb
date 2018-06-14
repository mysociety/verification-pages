# frozen_string_literal: true

# Decorator with merges statements with up-to-date position held data
class StatementDecorator < SimpleDelegator
  attr_reader :data
  attr_accessor :type

  def initialize(statement, position_held_data)
    @data = position_held_data
    statement.person_revision ||= data&.revision
    statement.statement_uuid ||= data&.position
    super(statement)
  end

  def done?
    verified? && reconciled? &&
      person_matches? &&
      electoral_district_item.present? && electoral_district_item == data&.district &&
      parliamentary_term_item.present? && parliamentary_term_item == data&.term &&
      (parliamentary_group_item.blank? || parliamentary_group_item == data&.group)
  end

  def problems
    electoral_district_problems +
      parliamentary_group_problems +
      start_date_before_term_problems
  end

  def start_date_before_term_problems
    return [] unless data&.start_date && data&.start_of_term &&
      Date.parse(data.start_date) < Date.parse(data.start_of_term) - 1.day
    [ "On Wikidata, the position held start date (#{data&.start_date}) was before the term start date (#{data&.start_of_term})" ]
  end

  def electoral_district_problems
    return [] unless data&.district && electoral_district_item != data&.district
    [ "The electoral district is different in the statement (#{electoral_district_item}) and on Wikidata (#{data&.district})" ]
  end

  def parliamentary_group_problems
    return [] unless data&.group && parliamentary_group_item != data&.group
    [ "The parliamentary group (party) is different in the statement (#{parliamentary_group_item}) and on Wikidata (#{data&.group})" ]
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

  def actioned?
    actioned_at?
  end

  private

  def person_matches?
    person_item.present? && [data&.person, data&.merged_then_deleted].include?(person_item)
  end
end

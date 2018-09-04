# frozen_string_literal: true

# Decorator with merges statements with up-to-date position held data
class StatementDecorator < SimpleDelegator
  attr_accessor :type

  def initialize(statement, matching_position_held_data)
    @matching_position_held_data = matching_position_held_data
    statement.person_revision ||= data&.revision
    statement.statement_uuid ||= data&.position
    super(statement)
  end

  def data
    matching_position_held_data.first
  end

  def matches_wikidata?
    reconciled? &&
      person_matches? &&
      electoral_district_matches? &&
      parliamentary_term_matches? &&
      parliamentary_group_matches?
  end

  def matches_but_not_checked?
    latest_verification.nil? && matches_wikidata?
  end

  def done?
    verified? && matches_wikidata?
  end

  def problems
    if statement_problems.any?
      statement_problems
    else
      electoral_district_problems +
        parliamentary_group_problems +
        start_date_before_term_problems +
        reported_problems
    end
  end

  def start_date_before_term_problems
    return [] unless data&.position_start && data&.term_start &&
                     Date.parse(data.position_start) < Date.parse(data.term_start) - 31.days
    ["On Wikidata, the position held start date (#{data&.position_start}) was before the term start date (#{data&.term_start})"]
  end

  def electoral_district_problems
    return [] if electoral_district_item.blank?
    return [] unless data&.district && electoral_district_item != data&.district
    ["The electoral district is different in the statement (#{electoral_district_item}) and on Wikidata (#{data&.district})"]
  end

  def parliamentary_group_problems
    return [] unless data&.group && parliamentary_group_item != data&.group
    ["The parliamentary group (party) is different in the statement (#{parliamentary_group_item}) and on Wikidata (#{data&.group})"]
  end

  def statement_problems
    if matching_position_held_data.length > 1
      [
        "There were #{matching_position_held_data.length} 'position held' (P39) statements on Wikidata that match the verified suggestion - " \
        'one or more of them might be missing an end date or parliamentary term qualifier',
      ]
    elsif actioned? && matching_position_held_data.empty?
      ["There were no 'position held' (P39) statements on Wikidata that match the actioned suggestion"]
    else
      []
    end
  end

  def reported_problems
    return [] unless problem_reported?
    [error_reported]
  end

  def problem_reported?
    reported_at.present?
  end

  def unverifiable?
    unverifiable_due_to_party? ||
      latest_verification && latest_verification.status == false
  end

  def verified?
    latest_verification && latest_verification.status == true
  end

  def reconciled?
    reconciliations.empty?
  end

  def actioned?
    actioned_at?
  end

  def reconciliations
    person_reconciliations + party_reconciliations + district_reconciliations
  end

  def person_reconciliations
    return [] if person_item.present?
    ['person']
  end

  def party_reconciliations
    return [] if !page.require_parliamentary_group? ||
                 parliamentary_group_item.present?
    ['party']
  end

  def district_reconciliations
    return [] if electoral_district_item.present? || electoral_district_name.blank?
    ['district']
  end

  def verified_on
    latest_verification.try(:created_at).try(:to_date)
  end

  private

  attr_reader :matching_position_held_data

  def unverifiable_due_to_party?
    page.require_parliamentary_group? && parliamentary_group_name.blank? && parliamentary_group_item.blank?
  end

  def merged_then_deleted
    return [] if data&.merged_then_deleted.blank?
    data&.merged_then_deleted.split.map { |item| item.split('/').last }
  end

  def person_matches?
    person_item.present? && ([data&.person] + merged_then_deleted).include?(person_item)
  end

  def electoral_district_matches?
    return true if page.executive_position?
    electoral_district_item.blank? || electoral_district_item == data&.district
  end

  def parliamentary_term_matches?
    parliamentary_term_item.blank? || parliamentary_term_item == data&.term
  end

  def parliamentary_group_matches?
    return true if page.executive_position?
    parliamentary_group_item.blank? || parliamentary_group_item == data&.group
  end
end

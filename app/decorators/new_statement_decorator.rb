# frozen_string_literal: true

# Decorator with merges statements with up-to-date position held data
class NewStatementDecorator < SimpleDelegator
  attr_accessor :comparison, :type

  def initialize(statement, comparison)
    @comparison = comparison
    super(statement)
  end

  def statement_uuid
    if exact?
      comparison.exact_matches.first
    elsif conflict?
      comparison.conflicts.first
    else
      comparison.partial_matches.first
    end
  end

  def exact?
    !comparison.exact_matches.empty?
  end

  def conflict?
    !exact? && !comparison.conflicts.empty?
  end

  def matches_wikidata?
    reconciled? && exact?
  end

  def matches_but_not_checked?
    latest_verification.nil? && matches_wikidata?
  end

  def unverifiable?
    latest_verification && latest_verification.status == false
  end

  def recently_actioned?
    # Was this statement actioned in the last 5 minutes?
    return false unless actioned_at?
    time_difference_seconds = Time.zone.now - actioned_at
    (time_difference_seconds / 60.0) < 5
  end

  def done?
    recently_actioned? ||
      (verified? && matches_wikidata?) ||
      (!from_suggestions_store? && matches_but_not_checked?)
  end

  def reverted?
    !done? && actioned_at? && statement_uuid
  end

  def done_or_reverted?
    done? || reverted?
  end

  def manually_actionable?
    !reverted? && reconciled? && !problems.empty?
  end

  def actionable?
    !manually_actionable? && verified? && reconciled?
  end

  def verified?
    latest_verification && latest_verification.status == true
  end

  def reconciled?
    reconciliations_required.empty?
  end

  def problems
    conflicted_problems + reported_problems + actioned_but_no_statement_problem
  end

  def conflicted_problems
    return [] if statement_uuid && !conflict?
    comparison.problems.fetch(statement_uuid, [])
  end

  def reported_problems
    return [] unless problem_reported?
    [error_reported]
  end

  def actioned_but_no_statement_problem
    return [] unless actioned_at? && !statement_uuid
    ["There were no 'position held' (P39) statements on Wikidata that match the actioned suggestion"]
  end

  def problem_reported?
    reported_at.present?
  end

  def reconciliations_required
    person_reconciliations + party_reconciliations + district_reconciliations
  end

  def person_reconciliations
    return [] if person_item.present?
    ['person']
  end

  def party_reconciliations
    return [] if parliamentary_group_item.present? || parliamentary_group_name.blank?
    ['party']
  end

  def district_reconciliations
    return [] if electoral_district_item.present? || electoral_district_name.blank?
    ['district']
  end

  def verified_on
    latest_verification.try(:created_at).try(:to_date)
  end
end

# frozen_string_literal: true

require 'membership_comparison'

# Service to classify statements into actionable, manually_actionable or done groups
class NewStatementClassifier
  attr_reader :page, :statements, :transaction_id

  def initialize(page_title, transaction_ids: [])
    @page = Page.find_by!(title: page_title)
    @statements = page.statements.original
                      .includes(:verifications)
                      .references(:verifications)
                      .order(:id)

    return if transaction_ids.empty?
    @transaction_id = transaction_ids.first if transaction_ids.count == 1
    @statements = @statements.where(transaction_id: transaction_ids)
  end

  # verifiable
  # unverifiable
  # reconcilable
  # actionable
  # manually_actionable
  # done
  # reverted
  # removed

  def verifiable
    classified_statements.fetch(:verifiable, [])
  end

  def unverifiable
    classified_statements.fetch(:unverifiable, [])
  end

  def reconcilable
    classified_statements.fetch(:reconcilable, [])
  end

  def actionable
    classified_statements.fetch(:actionable, [])
  end

  def manually_actionable
    classified_statements.fetch(:manually_actionable, [])
  end

  def done
    classified_statements.fetch(:done, [])
  end

  def reverted
    classified_statements.fetch(:reverted, [])
  end

  def removed
    classified_statements.fetch(:removed, [])
  end

  def to_a
    statements.to_a
              .map { |s| decorate_statement(s) }
              .select(&:type) # remove statements without a type
  end

  private

  def classified_statements
    @classified_statements ||= to_a.each_with_object({}) do |statement, h|
      h[statement.type] ||= []
      h[statement.type] << statement
    end
  end

  def statement_type(statement)
    if statement.removed_from_source? && !statement.done_or_reverted?
      nil
    elsif statement.removed_from_source? && statement.done_or_reverted?
      :removed
    elsif statement.unverifiable?
      :unverifiable
    elsif statement.done?
      :done
    elsif statement.reverted?
      :reverted
    elsif statement.manually_actionable?
      :manually_actionable
    elsif statement.actionable?
      :actionable
    elsif statement.verified?
      :reconcilable
    else
      :verifiable
    end
  end

  def decorate_statement(statement)
    comparison = comparison_for_statement(statement)
    NewStatementDecorator.new(statement, comparison).tap do |s|
      s.type = statement_type(s)
    end
  end

  def person_item_from_transaction_id
    return unless transaction_id
    statements.first.person_item
  end

  def position_held_data
    @position_held_data ||= NewRetrievePositionData.run(
      page.position_held_item,
      person_item_from_transaction_id
    )
  end

  def parliamentary_term_data
    @parliamentary_term_data ||= RetrieveTermData.run(
      page.parliamentary_term_item
    )
  end

  def comparison_for_statement(statement)
    MembershipComparison.new(
      existing:   existing_statements_for_person(statement.person_item),
      suggestion: mapped_statement(statement)
    )
  end

  def merged_then_deleted(data)
    data.merged_then_deleted.split.map { |item| item.split('/').last }
  end

  def existing_statements_for_person(person_item)
    position_held_data.each_with_object({}) do |data, memo|
      person_items = [data.person] + merged_then_deleted(data)
      next unless person_items.include?(person_item)

      memo[data.position] = {
        position: { id: page.position_held_item },
        start:    data.position_start,
        end:      data.position_end,
        term:     {
          id:    data.term,
          start: data.term_start,
          end:   data.term_end,
        },
        party:    { id: data.group },
        district: { id: data.district },
        data:     {
          statement_uuid: data.position,
          revision:       data.revision,
        },
      }
    end
  end

  def mapped_statement(statement)
    {
      position: { id: page.position_held_item },
      term:     {
        id:    page.parliamentary_term_item.presence,
        start: parliamentary_term_data.start,
        end:   parliamentary_term_data.end,
        eopt:  parliamentary_term_data.previous_term_end,
        sont:  parliamentary_term_data.next_term_start,
      },
      party:    { id: statement.parliamentary_group_item },
      district: { id: !page.executive_position? ? statement.electoral_district_item : nil },
      start:    statement.position_start,
      end:      statement.position_end,
    }
  end
end

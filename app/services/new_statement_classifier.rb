# frozen_string_literal: true

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
    data = matching_position_held_data(statement)
    NewStatementDecorator.new(statement, data).tap do |s|
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
      page.parliamentary_term_item,
      person_item_from_transaction_id
    )
  end

  def merged_then_deleted(data)
    data.merged_then_deleted.split.map { |item| item.split('/').last }
  end

  def matching_position_held_data(statement)
    position_held_data.select do |data|
      ([data.person] + merged_then_deleted(data)).include?(statement.person_item)
    end
  end
end
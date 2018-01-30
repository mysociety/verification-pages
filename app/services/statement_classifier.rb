# frozen_string_literal: true

# Service to classify statements into actionable, manual or evidenced groups
class StatementClassifier
  include Enumerable

  attr_reader :page, :statements

  def initialize(page_title)
    @page = Page.find_by!(title: page_title)
    @statements = page.statements
  end

  def actionable
    classified_statements.fetch(:actionable, [])
  end

  def manual
    classified_statements.fetch(:manual, [])
  end

  def evidenced
    classified_statements.fetch(:evidenced, [])
  end

  private

  def classified_statements
    @classified_statements ||= each_with_object({}) do |statement, h|
      type = statement_type(statement)
      next unless type

      h[type] ||= []
      h[type] << statement
    end
  end

  def statement_type(statement)
    return unless statement.data
    return if statement.term_invalid? || statement.result_negative?

    if statement.result_positive?
      :evidenced
    elsif statement.started_before_term? || statement.qualifiers_contradicting?
      :manual
    else
      :actionable
    end
  end

  def each
    statements.map do |statement|
      yield decorate_statement(statement)
    end
  end

  def decorate_statement(statement)
    StatementDecorator.new(statement, position_data_for_statement(statement))
  end

  def position_held_data
    @position_held_data ||= RetrievePositionData.run(page.position_held_item)
  end

  def position_data_for_statement(statement)
    position_held_data.detect { |data| data.person == statement.person_item }
  end
end
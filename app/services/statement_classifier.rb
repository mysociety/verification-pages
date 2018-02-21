# frozen_string_literal: true

# Service to classify statements into actionable, manual or evidenced groups
class StatementClassifier
  attr_reader :page, :statements

  def initialize(page_title)
    @page = Page.find_by!(title: page_title)
    @statements = page.statements.includes(:verifications)
                      .references(:verifications)
  end

  def verifiable
    classified_statements.fetch(:verifiable, [])
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
    @classified_statements ||= decorated_statements
                               .each_with_object({}) do |statement, h|
      type = statement_type(statement)
      next unless type

      h[type] ||= []
      h[type] << statement
    end
  end

  def statement_type(statement)
    if statement.term_invalid? ||
       statement.reconciliation_negative? ||
       statement.unverifiable?
      # noop
    elsif statement.reconciliation_positive?
      :evidenced
    elsif statement.started_before_term? || statement.qualifiers_contradicting?
      :manual
    elsif statement.verified?
      :actionable
    else
      :verifiable
    end
  end

  def decorated_statements
    statements.to_a.map do |statement|
      decorate_statement(statement)
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

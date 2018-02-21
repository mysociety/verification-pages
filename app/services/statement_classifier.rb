# frozen_string_literal: true

# Service to classify statements into actionable, manually_actionable or done groups
class StatementClassifier
  attr_reader :page, :statements

  def initialize(page_title)
    @page = Page.find_by!(title: page_title)
    @statements = page.statements.includes(:verifications)
                      .references(:verifications)
  end

  # verifiable
  # unverifiable
  # reconcilable
  # actionable
  # manually_actionable
  # done(able)
  #

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

  def to_a
    decorated_statements.map do |decorated_statement|
      decorated_statement.tap do |s|
        s.type = statement_type(s)
      end
    end
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
    if statement.done?
      :done
    elsif statement.reconciled? && (statement.started_before_term? || statement.qualifiers_contradicting?)
      :manually_actionable
    elsif statement.reconciled?
      :actionable
    elsif statement.verified?
      :reconcilable
    elsif statement.unverifiable?
      :unverifiable
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

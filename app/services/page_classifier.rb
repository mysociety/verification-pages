# frozen_string_literal: true

require 'membership_comparison'

# Service to classify a page's statements into groups based on if we can submit
# data to Wikidata or not
class PageClassifier
  attr_reader :page, :transaction_id

  VERSION = 'v2'

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

  def statements
    update_page_position_if_merged
    return [] unless @statements

    @statements.each_with_object([]) do |statement, memo|
      existing_statements = position_held_data.select do |data|
        person_items = [data.person] + merged_then_deleted(data)
        person_items.include?(statement.person_item)
      end

      item_data = item_data_for_statement(statement)

      items = { term: parliamentary_term_data, group: item_data[statement.parliamentary_group_item] }
      items[:district] = item_data[statement.electoral_district_item] unless page.executive_position?

      decorated_statement = StatementClassifier.new(
        statement:           statement,
        existing_statements: existing_statements,
        items:               items
      ).decorate

      # skip statements without a type
      memo << decorated_statement if decorated_statement.type
    end
  end

  private

  def classified_statements
    @classified_statements ||= statements.each_with_object({}) do |statement, h|
      h[statement.type] ||= []
      h[statement.type] << statement
    end
  end

  def person_item_from_transaction_id
    return unless transaction_id
    @statements.first.person_item
  end

  def update_page_position_if_merged
    page.update(position_held_item: position.real_item) if position&.merged?
  end

  def position
    @position ||= items[page.position_held_item]
  end

  def items
    @items ||= begin
      item_values = @statements.each_with_object([]) do |statement, memo|
        memo << statement.parliamentary_group_item
        memo << statement.electoral_district_item
      end.compact.uniq << page.position_held_item

      RetrieveItems.run(*item_values)
    end
  end

  def item_data_for_statement(statement)
    item_values = [statement.person_item, statement.parliamentary_group_item, statement.electoral_district_item]
    items.select { |k| item_values.include?(k) }
  end

  def position_held_data
    return [] unless position&.item

    @position_held_data ||= RetrievePositionData.run(
      position.item,
      person_item_from_transaction_id
    )
  end

  def parliamentary_term_data
    @parliamentary_term_data ||= RetrieveTermData.run(
      page.parliamentary_term_item
    )
  end

  def merged_then_deleted(data)
    data.merged_then_deleted.split.map { |item| item.split('/').last }
  end
end

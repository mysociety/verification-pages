# frozen_string_literal: true

require 'membership_comparison'

# Service to classify statements into actionable, manually_actionable or done groups
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

    @statements.map do |statement|
      StatementClassifier.new(
        page:                    page,
        statement:               statement,
        position:                position,
        position_held_data:      position_held_data,
        parliamentary_term_data: parliamentary_term_data
      ).decorate
    end.select(&:type) # remove statements without a type
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
    @position ||= RetrieveItems.one(page.position_held_item)
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
end

class StatementClassifier
  attr_reader :page, :statement, :position_held_data, :parliamentary_term_data

  def initialize(page:, statement:, position:, position_held_data:, parliamentary_term_data:)
    @page = page
    @statement = statement
    @position = position
    @position_held_data = position_held_data
    @parliamentary_term_data = parliamentary_term_data
  end

  def decorate
    StatementDecorator.new(statement, comparison)
  end

  private

  def comparison
    MembershipComparison.new(
      existing:   existing_statements,
      suggestion: suggested_statement
    )
  end

  def merged_then_deleted(data)
    data.merged_then_deleted.split.map { |item| item.split('/').last }
  end

  def existing_statements
    position_held_data.each_with_object({}) do |data, memo|
      person_items = [data.person] + merged_then_deleted(data)
      next unless person_items.include?(statement.person_item)

      memo[data.position] = {
        start:    data.position_start,
        end:      data.position_end,
        term:     {
          id:    data.term,
          start: data.term_start,
          end:   data.term_end,
        },
        party:    { id: data.group },
        district: { id: data.district },
      }
    end
  end

  def suggested_statement
    {
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

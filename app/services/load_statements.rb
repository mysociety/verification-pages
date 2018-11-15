# frozen_string_literal: true

require 'csv'
require 'digest'

class LoadStatements < ServiceBase
  attr_reader :page

  def initialize(page_title)
    @page = Page.find_by!(title: page_title)
  end

  def run
    touched_statements = csv.map { |result| parse_result(result) }
    untouched_statements = page.statements.where.not(id: touched_statements)
    untouched_statements.update(removed_from_source: true)
    touched_statements
  end

  private

  def parse_result(result)
    result[:transaction_id] ||= page.generate_transaction_id(result.to_h)

    statement = page.statements.find_or_initialize_by(
      transaction_id: result[:transaction_id]
    )

    # We need to be careful not wipe out any manually reconciled
    # items when refreshing from the upstream CSV file, so don't
    # overwrite the *_item attributes if that'd make them blank:
    Reconciliation.resource_mappings.each do |type, attributes|
      attribute = attributes[:item]
      reconciliation = statement.reconciliations
                                .where(resource_type: type)
                                .last
      value = reconciliation ? reconciliation.item : result[attribute]
      statement.public_send("#{attribute}=", value) if value.present?
    end

    # The other attributes we always update from the upstream CSV:
    statement.update!(
      page:                     page,
      person_name:              result[:person_name],
      electoral_district_name:  result[:electoral_district_name],
      parliamentary_group_name: result[:parliamentary_group_name],
      fb_identifier:            result[:fb_identifier],
      position_start:           result[:position_start],
      position_end:             result[:position_end],
      removed_from_source:      false
    )

    statement
  end

  def csv
    @csv ||= CSV.parse(raw_data, headers: true, header_converters: :symbol,
                                 converters: nil)
  end

  def raw_data
    RestClient.get(page.csv_source_url).body
  rescue RestClient::Exception => e
    raise "Suggestion store failed: #{e.message}"
  end
end

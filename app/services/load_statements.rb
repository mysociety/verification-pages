# frozen_string_literal: true

require 'csv'
require 'digest'

class LoadStatements < ServiceBase
  attr_reader :page

  def initialize(page_title)
    @page = Page.find_by!(title: page_title)
  end

  def run
    Statement.transaction do
      touched_statements = csv.map { |data| Row.new(data, page: page).parse }
      untouched_statements = page.statements.where.not(id: touched_statements)
      untouched_statements.update(removed_from_source: true)
      touched_statements.each(&:save!)
      touched_statements
    end
  end

  private

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

class Row < OpenStruct
  attr_reader :data, :page

  def initialize(data, page:)
    @data = data.to_h
    @page = page
    super(@data)
  end

  def transaction_id
    super || page.generate_transaction_id(data)
  end

  def electoral_district_name
    super || area || constituency || district
  end

  def electoral_district_item
    find_qids(super, area_id, constituency_id, district_id).first
  end

  def parliamentary_group_name
    super || alliance || coalition || faction || party || group
  end

  def parliamentary_group_item
    find_qids(super, alliance_id, coalition_id, faction_id, party_id, group_id).first
  end

  def person_name
    super || name
  end

  def person_item
    find_qids(super, wikidata, id).first
  end

  def position_start
    super || start_date
  end

  def position_end
    super || start_end
  end

  def parse
    # We need to be careful not wipe out any manually reconciled
    # items when refreshing from the upstream CSV file, so don't
    # overwrite the *_item attributes if that'd make them blank:
    Reconciliation.resource_mappings.each do |type, attributes|
      attribute = attributes[:item]
      reconciliation = statement.reconciliations
                                .where(resource_type: type)
                                .last
      value = reconciliation ? reconciliation.item : public_send(attribute)
      statement.public_send("#{attribute}=", value) if value.present?
    end

    # The other attributes we always update from the upstream CSV:
    statement.assign_attributes(
      page:                     page,
      person_name:              person_name,
      electoral_district_name:  electoral_district_name,
      parliamentary_group_name: parliamentary_group_name,
      fb_identifier:            fb_identifier,
      position_start:           position_start,
      position_end:             position_end,
      removed_from_source:      false
    )

    statement
  end

  private

  def statement
    @statement ||= page.statements.find_or_initialize_by(
      transaction_id: transaction_id
    )
  end

  def area_id
    find_qids(super, area_wikidata, wikidata_area).first
  end

  def constituency_id
    find_qids(super, constituency_wikidata, wikidata_constituency).first
  end

  def district_id
    find_qids(super, district_wikidata, wikidata_district).first
  end

  def alliance_id
    find_qids(super, alliance_wikidata, wikidata_alliance).first
  end

  def coalition_id
    find_qids(super, coalition_wikidata, wikidata_coalition).first
  end

  def faction_id
    find_qids(super, faction_wikidata, wikidata_faction).first
  end

  def party_id
    find_qids(super, party_wikidata, wikidata_party).first
  end

  def group_id
    find_qids(super, group_wikidata, wikidata_group).first
  end

  def find_qids(*args)
    args.select { |id| id && id =~ /^Q\d+$/ }
  end
end

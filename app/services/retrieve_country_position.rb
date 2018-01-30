# frozen_string_literal: true

# Service to query Wikidata for the top level position associated with a country
#
# Examples:
#   Q30524710 "member of the 57th Parliament of the United Kingdom" returns
#   Q16707842 "member of Parliament in the United Kingdom"
#
#   Q15964890 "member of the House of Commons of Canada" returns
#   Q15964890 "member of the House of Commons of Canada"
#
# Also returned is the ISO 3166-1 alpha 2 country code of the country associated
# with the position
class RetrieveCountryPosition < ServiceBase
  include SparqlQuery

  Error = Class.new(StandardError)

  attr_reader :position_held_item

  def initialize(position_held_item)
    @position_held_item = position_held_item
  end

  def run
    data || raise(RetrieveCountryPosition::Error,
                  "Couldn't find position_held role assoicated with a country")
  end

  private

  def data
    @data ||= run_query(format(query, position_held_item: position_held_item))
              .first
  end

  def query
    <<~SPARQL
      SELECT ?position ?country WHERE {
        wd:%<position_held_item>s wdt:P279* ?position .
        ?position wdt:P17/wdt:P297 ?country .
      }
    SPARQL
  end
end

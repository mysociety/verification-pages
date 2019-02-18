# frozen_string_literal: true

# Fetches country from position held or parliamentary term items from Wikidata.
class RetrieveCountry < ServiceBase
  include SparqlQuery

  attr_reader :position_held_item, :parliamentary_term_item

  def initialize(position_held_item, parliamentary_term_item)
    @position_held_item = position_held_item
    @parliamentary_term_item = parliamentary_term_item
  end

  def run
    run_query(query).first
  end

  def query
    query_format % { position_held_item:      position_held_item,
                     parliamentary_term_item: parliamentary_term_item, }
  end

  private

  def query_format
    <<~SPARQL
      SELECT DISTINCT
        ?country
      WHERE {
        BIND(wd:%<position_held_item>s AS ?position)
        BIND(wd:%<parliamentary_term_item>s AS ?term)

        OPTIONAL { ?position wdt:P17 ?position_country . }
        OPTIONAL { ?term wdt:P17 ?term_country . }

        BIND(COALESCE(?position_country, ?term_country) AS ?country)

        FILTER(?position_country = ?term_country || !BOUND(?position_country) || !BOUND(?term_country))
      }
      LIMIT 1
    SPARQL
  end
end

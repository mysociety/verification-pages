# frozen_string_literal: true

# Fetches parliamentary term data from Wikidata.
class RetrieveTermData < ServiceBase
  include SparqlQuery

  attr_reader :parliamentary_term_item

  def initialize(parliamentary_term_item)
    @parliamentary_term_item = parliamentary_term_item
  end

  def run
    run_query(query).first
  end

  def query
    query_format % { parliamentary_term_item: parliamentary_term_item }
  end

  private

  def query_format
    <<~SPARQL
      SELECT DISTINCT
        ?term ?start ?end
      WHERE {
        BIND(wd:%<parliamentary_term_item>s AS ?term)

        # page term start/end dates
        OPTIONAL { ?term wdt:P580 ?_start }
        OPTIONAL { ?term wdt:P571 ?_inception}
        BIND(COALESCE(?_start, ?_inception) AS ?start)
        OPTIONAL { ?term wdt:P582 ?_end }
        OPTIONAL { ?term wdt:P576 ?_dissolved }
        BIND(COALESCE(?_end, ?_dissolved) AS ?end)
      }
      LIMIT 1
    SPARQL
  end
end

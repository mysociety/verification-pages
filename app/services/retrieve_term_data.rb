# frozen_string_literal: true

# Fetches parliamentary term data from Wikidata.
class RetrieveTermData < ServiceBase
  include SparqlQuery

  attr_reader :parliamentary_term_item

  def initialize(parliamentary_term_item)
    @parliamentary_term_item = parliamentary_term_item
  end

  def run
    result = run_query(query).first

    %i[start end previous_term_end next_term_start].each do |key|
      result[key] = Date.parse(result[key]) if result[key]
    end

    result
  end

  def query
    query_format % { parliamentary_term_item: parliamentary_term_item }
  end

  private

  def query_format
    <<~SPARQL
      SELECT DISTINCT
        ?term ?start ?end ?previous_term_end ?next_term_start
      WHERE {
        BIND(wd:%<parliamentary_term_item>s AS ?term)

        OPTIONAL { ?term wdt:P580 ?start. }
        OPTIONAL { ?term wdt:P571 ?start. }
        OPTIONAL { ?term wdt:P582 ?end. }
        OPTIONAL { ?term wdt:P576 ?end. }

        OPTIONAL { ?term wdt:P155 ?previous_term. }
        OPTIONAL { ?term wdt:P1365 ?previous_term. }
        OPTIONAL { ?previous_term wdt:P582 ?previous_term_end. }
        OPTIONAL { ?previous_term wdt:P576 ?previous_term_end. }

        OPTIONAL { ?term wdt:P156 ?next_term. }
        OPTIONAL { ?term wdt:P1366 ?next_term. }
        OPTIONAL { ?next_term wdt:P580 ?next_term_start. }
        OPTIONAL { ?next_term wdt:P571 ?next_term_start. }
      }
      LIMIT 1
    SPARQL
  end
end

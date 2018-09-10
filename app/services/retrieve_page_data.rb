# frozen_string_literal: true

# Service to fetch position term data from a SPARQL query
class RetrievePageData < ServiceBase
  include SparqlQuery

  attr_reader :position, :term

  def initialize(position, term)
    @position = position
    @term = term
  end

  def run
    run_query(query).first
  end

  def query
    query_format % { position: position, term: term }
  end

  private

  def query_format
    <<~SPARQL
      SELECT DISTINCT
        ?position ?position_name
        ?term ?term_name
      WHERE {
        BIND(wd:%<position>s AS ?position)
        BIND(wd:%<term>s AS ?term)
        ?position rdfs:label ?position_name filter (lang(?position_name) = "en") .
        ?term rdfs:label ?term_name filter (lang(?term_name) = "en") .
      }
    SPARQL
  end
end

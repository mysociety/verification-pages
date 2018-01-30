# frozen_string_literal: true

# Mixin to easily preform SPARQL queries
module SparqlQuery
  WIKIDATA_SPARQL_URL = 'https://query.wikidata.org/sparql'

  attr_reader :json

  def run_query(query)
    @json = sparql(query)
    bindings.map { |r| SparqlResult.new(r, variables) }
  end

  private

  def sparql(query)
    result = RestClient.get(
      WIKIDATA_SPARQL_URL,
      accept: 'application/sparql-results+json',
      params: { query: query }
    )
    JSON.parse(result, symbolize_names: true)
  rescue RestClient::Exception => e
    raise "Wikidata query #{query} failed: #{e.message}"
  end

  def bindings
    json[:results][:bindings]
  end

  def variables
    json[:head][:vars]
  end
end

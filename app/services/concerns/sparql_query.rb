# frozen_string_literal: true

# Mixin to easily preform SPARQL queries
module SparqlQuery
  WIKIDATA_SPARQL_URL = 'https://query.wikidata.org/sparql'

  attr_reader :json

  def run_query(query)
    @json = sparql(query)
    bindings.map do |r|
      result = r.extend(SparqlResult)
      result.variables = variables
      result
    end
  end

  private

  def sparql(query)
    result = RestClient.post(
      WIKIDATA_SPARQL_URL,
      { query: query },
      accept: 'application/sparql-results+json'
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

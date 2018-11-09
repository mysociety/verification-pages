# frozen_string_literal: true

# Service to fetch labels of Wikidata items from a SPARQL query
class RetrieveItems < ServiceBase
  include SparqlQuery

  attr_reader :items

  def initialize(*items)
    @items = items
  end

  def run
    run_query(query).each_with_object({}) do |result, memo|
      memo[result.item] = result.label if result.label.present?
    end
  end

  def query
    query_format % { items: item_values }
  end

  private

  def item_values
    items.select { |item| item =~ /Q\d+/ }
         .map { |item| "(wd:#{item})" }.join(' ')
  end

  def query_format
    <<~SPARQL
      SELECT
        ?item ?label
      WHERE {
        VALUES (?item) {
          %<items>s
        }
        OPTIONAL { ?item owl:sameAs ?mergedInTo }
        BIND(COALESCE(?mergedInTo, ?item) AS ?realItem)
        SERVICE wikibase:label {
          bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en" .
          ?realItem rdfs:label ?label .
        }
      }
    SPARQL
  end
end

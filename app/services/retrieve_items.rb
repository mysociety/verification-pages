# frozen_string_literal: true

# Service to run a SPARQL query to fetch an multiple items' labels and if they
# have been merged
class RetrieveItems < ServiceBase
  include SparqlQuery

  attr_reader :items

  def initialize(*items)
    @items = items
  end

  def run
    run_query(query).each_with_object({}) do |result, memo|
      memo[result.item] = result
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
        ?item ?real_item ?label ?merged
      WHERE {
        VALUES (?item) {
          %<items>s
        }
        OPTIONAL { ?item owl:sameAs ?real_item }
        BIND(COALESCE(?real_item, ?item) AS ?real_item)
        BIND (?real_item != $item AS ?merged)
        SERVICE wikibase:label {
          bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en" .
          ?real_item rdfs:label ?label .
        }
      }
    SPARQL
  end
end

# frozen_string_literal: true

# Service to run a SPARQL query to fetch an multiple items' labels and if they
# have been merged
class RetrieveItems < ServiceBase
  include SparqlQuery

  attr_reader :items

  def self.one(arg)
    run(arg)[arg]
  end

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
        ?item ?real_item ?label ?merged ?disambiguation
      WHERE {
        VALUES (?item) {
          %<items>s
        }
        BIND(wd:Q4167410 AS ?disambiguation_page)

        OPTIONAL { ?item owl:sameAs ?real_item }
        BIND(COALESCE(?real_item, ?item) AS ?real_item)
        BIND (?real_item != $item AS ?merged)
        OPTIONAL { ?real_item wdt:P31 ?instance_of }
        BIND(?instance_of = ?disambiguation_page AS ?disambiguation) .

        SERVICE wikibase:label {
          bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en" .
          ?real_item rdfs:label ?label .
        }
      }
    SPARQL
  end
end

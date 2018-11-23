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
      result[:children] = [
        { item: result.delete(:child), label: result.delete(:child_label) },
      ].reject { |child| child.compact.empty? }

      memo[result[:item]][:children] += result[:children] if memo[result[:item]]
      memo[result[:item]] ||= result
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
        ?disambiguation
        ?parent ?parent_label
        ?child ?child_label
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

        OPTIONAL { ?item wdt:P279 ?parent }

        OPTIONAL { ?child wdt:P279 ?item }

        SERVICE wikibase:label {
          bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en" .
          ?real_item rdfs:label ?label .
          ?parent rdfs:label ?parent_label .
          ?child rdfs:label ?child_label .
        }
      }
    SPARQL
  end
end

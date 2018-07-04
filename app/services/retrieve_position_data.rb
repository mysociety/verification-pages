# frozen_string_literal: true

# Service to fetch position held data from a SPARQL query
class RetrievePositionData < ServiceBase
  include SparqlQuery

  attr_reader :position_held_item, :parliamentary_term_item, :person_item

  def initialize(position_held_item, parliamentary_term_item = nil, person_item = nil)
    @position_held_item = position_held_item
    @parliamentary_term_item = parliamentary_term_item
    @person_item = person_item
  end

  def run
    run_query(query)
  end

  def query
    format(
      query_format,
      position_held_item: position_held_item,
      parliamentary_term_item: parliamentary_term_item,
      person_bind: person_bind
    )
  end

  private

  def query_format
    <<~SPARQL
      SELECT DISTINCT ?person ?merged_then_deleted ?revision ?position ?term_start ?start_date ?term ?group ?district
      WHERE {
        %<person_bind>s
        BIND(wd:%<parliamentary_term_item>s AS ?page_term)
        ?position ps:P39 wd:%<position_held_item>s .
        ?person wdt:P31 wd:Q5 ; p:P39 ?position .
        ?person schema:version ?revision .
        OPTIONAL {
          ?position pq:P2937 ?term .
          OPTIONAL { ?term (wdt:P571|wdt:P580) ?term_start . }
        }
        OPTIONAL { ?page_term (wdt:P571|wdt:P580) ?start_of_page_term . }
        OPTIONAL { ?position pq:P4100 ?group . }
        OPTIONAL { ?position pq:P768 ?district . }
        OPTIONAL { ?position pq:P580 ?start_date . }
        OPTIONAL { ?merged_then_deleted owl:sameAs ?person }
        FILTER (
          !bound(?start_of_page_term) || !bound(?start_date) ||
          ?start_of_page_term <= ?start_date
        )
      }
    SPARQL
  end

  def person_bind
    return '' unless person_item
    "BIND(wd:#{person_item} AS ?person)"
  end
end

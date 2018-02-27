# frozen_string_literal: true

# Service to fetch position held data from a SPARQL query
class RetrievePositionData < ServiceBase
  include SparqlQuery

  attr_reader :position_held_item, :person_item

  def initialize(position_held_item, person_item = nil)
    @position_held_item = position_held_item
    @person_item = person_item
  end

  def run
    run_query(format(
      query,
      position_held_item: position_held_item,
      person_bind: person_bind
    ))
  end

  private

  def query
    <<~SPARQL
      SELECT DISTINCT ?person ?revision ?position ?start_of_term ?start_date ?term ?group ?district
      WHERE {
        %<person_bind>s
        ?position ps:P39 wd:%<position_held_item>s .
        ?person wdt:P31 wd:Q5 ; p:P39 ?position .
        ?person schema:version ?revision .
        OPTIONAL {
          ?position pq:P2937 ?term .
          OPTIONAL { ?term (wdt:P571|wdt:P580) ?start_of_term . }
        }
        OPTIONAL { ?position pq:P4100 ?group . }
        OPTIONAL { ?position pq:P768 ?district . }
        OPTIONAL { ?position pq:P580 ?start_date . }
      }
    SPARQL
  end

  def person_bind
    return '' unless person_item
    "BIND(wd:#{person_item} AS ?person)"
  end
end

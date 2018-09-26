# frozen_string_literal: true

# Fetches position held data from Wikidata.
class NewRetrievePositionData < ServiceBase
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
    query_format % { position_held_item:      position_held_item,
                     parliamentary_term_item: parliamentary_term_item,
                     person_bind:             person_bind, }
  end

  private

  def query_format
    <<~SPARQL
      SELECT DISTINCT
        ?person (GROUP_CONCAT(?merged_then_deleted) AS ?merged_then_deleted) ?revision
        ?position ?position_start ?position_end
        ?term ?term_start
        ?group ?district
      WHERE {
        %<person_bind>s
        BIND(wd:%<parliamentary_term_item>s AS ?page_term)
        BIND(wd:%<position_held_item>s AS ?position_held)
        ?position ps:P39 ?position_held .
        ?person wdt:P31 wd:Q5 ; p:P39 ?position .
        ?person schema:version ?revision .
        OPTIONAL { ?position pq:P2937 ?term . }
        OPTIONAL { ?page_term wdt:P571 ?inception_s }
        OPTIONAL { ?page_term wdt:P580 ?term_start_s }
        BIND(COALESCE(?term_start_s, ?inception_s) AS ?term_start)
        OPTIONAL { ?position pq:P4100 ?group . }
        OPTIONAL { ?position pq:P768 ?district . }
        OPTIONAL { ?merged_then_deleted owl:sameAs ?person }
      }
      GROUP BY ?person ?revision ?position ?position_start ?position_end ?term ?term_start ?group ?district
    SPARQL
  end

  def person_bind
    return '' unless person_item
    "BIND(wd:#{person_item} AS ?person)"
  end
end

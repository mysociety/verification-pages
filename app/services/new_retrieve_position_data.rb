# frozen_string_literal: true

# Fetches position held data from Wikidata.
class NewRetrievePositionData < ServiceBase
  include SparqlQuery

  attr_reader :position_held_item, :person_item

  def initialize(position_held_item, person_item = nil)
    @position_held_item = position_held_item
    @person_item = person_item
  end

  def run
    run_query(query)
  end

  def query
    query_format % { position_held_item: position_held_item,
                     person_bind:        person_bind, }
  end

  private

  def query_format
    <<~SPARQL
      SELECT DISTINCT
        ?person ?revision
        ?position ?position_start ?position_end
        ?term ?term_start ?term_end
        ?group ?district
        (GROUP_CONCAT(?merged_then_deleted) AS ?merged_then_deleted)
      WHERE {
        %<person_bind>s

        BIND(wd:%<position_held_item>s AS ?position_held)

        ?position ps:P39 ?position_held .

        ?person wdt:P31 wd:Q5 ; p:P39 ?position .
        ?person schema:version ?revision .

        # position start/end dates
        OPTIONAL { ?position pq:P580 ?position_start }
        OPTIONAL { ?position pq:P571 ?position_start}
        OPTIONAL { ?position pq:P582 ?position_end }
        OPTIONAL { ?position pq:P576 ?position_end }

        OPTIONAL {
          ?position pq:P2937 ?term .

          # term start/end dates
          OPTIONAL { ?term wdt:P580 ?term_start }
          OPTIONAL { ?term wdt:P571 ?term_start }
          OPTIONAL { ?term wdt:P582 ?term_end }
          OPTIONAL { ?term wdt:P576 ?term_end }
        }

        OPTIONAL { ?position pq:P4100 ?group . }
        OPTIONAL { ?position pq:P768 ?district . }

        OPTIONAL { ?merged_then_deleted owl:sameAs ?person }
      }
      GROUP BY ?person ?revision ?position ?position_start ?position_end ?term ?term_start ?term_end ?group ?district
    SPARQL
  end

  def person_bind
    return '' unless person_item
    "BIND(wd:#{person_item} AS ?person)"
  end
end

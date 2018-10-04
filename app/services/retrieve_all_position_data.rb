# frozen_string_literal: true

# Service to fetch position held data from a SPARQL query
class RetrieveAllPositionData < ServiceBase
  include SparqlQuery
  include Enumerable

  attr_reader :position_held

  def initialize(position_held)
    @position_held = position_held
  end

  def each
    idx = 0

    loop do
      query = queries[idx]
      break unless query

      results = run_query(queries[idx]).group_by(&:person)
      results.map { |item| yield item }
      idx += 1
    end
  end

  def people
    @people ||= run_query(
      <<~SPARQL % { position_held: position_held }
        SELECT DISTINCT ?person
        WHERE {
          BIND(wd:%<position_held>s AS ?position_held)

          ?position ps:P39 ?position_held .

          # Using distinct we can ignore people which have been merged
          ?_person wdt:P31 wd:Q5 ; p:P39 ?position .
          OPTIONAL { ?_person owl:sameAs ?mergedInTo . }
          BIND(COALESCE(?mergedInTo, ?_person) AS ?person)
        }
        ORDER BY ASC(xsd:integer(SUBSTR(STR(?person), STRLEN("http://www.wikidata.org/entity/Q")+1)))
      SPARQL
    ).map(&:person)
  end

  private

  def queries
    @queries ||= people.in_groups_of(500).map do |current_people|
      people = current_people.compact.map { |person| "(wd:#{person})" }.join(' ')
      query_format % { people: people }
    end
  end

  def query_format
    <<~SPARQL
      SELECT
        ?position_held ?parent_position_held
        ?person ?personLabel ?revision
        ?position ?position_start ?position_end
        ?term ?term_start ?term_end
        ?previous_term ?previous_term_start ?previous_term_end
        ?group ?district
      WHERE {
        VALUES (?person) { %<people>s }

        ?position ps:P39 ?position_held .
        OPTIONAL {
          ?position_held wdt:P279 ?parent_position_held .
          ?parent_position_held wdt:P17/wdt:P297 ?_country .
        }

        ?person wdt:P31 wd:Q5 ; p:P39 ?position .
        ?person schema:version ?revision .

        # position start/end dates
        OPTIONAL { ?position pq:P580 ?_position_start }
        OPTIONAL { ?position pq:P571 ?position_inception}
        BIND(COALESCE(?_position_start, ?position_inception) AS ?position_start)
        OPTIONAL { ?position pq:P582 ?_position_end }
        OPTIONAL { ?position pq:P576 ?position_dissolved }
        BIND(COALESCE(?_position_end, ?position_dissolved) AS ?position_end)

        OPTIONAL {
          ?position pq:P2937 ?term .

          # term start/end dates
          OPTIONAL { ?term wdt:P580 ?_term_start }
          OPTIONAL { ?term wdt:P571 ?_term_inception}
          BIND(COALESCE(?_term_start, ?_term_inception) AS ?term_start)
          OPTIONAL { ?term wdt:P582 ?_term_end }
          OPTIONAL { ?term wdt:P576 ?_term_dissolved }
          BIND(COALESCE(?_term_end, ?_term_dissolved) AS ?term_end)

          OPTIONAL {
            ?term wdt:P155 ?previous_term .

            # previous term start/end dates
            OPTIONAL { ?previous_term wdt:P580 ?_previous_term_start }
            OPTIONAL { ?previous_term wdt:P571 ?_previous_term_inception}
            BIND(COALESCE(?_previous_term_start, ?_previous_term_inception) AS ?previous_term_start)
            OPTIONAL { ?previous_term wdt:P582 ?_previous_term_end }
            OPTIONAL { ?previous_term wdt:P576 ?_previous_term_dissolved }
            BIND(COALESCE(?_previous_term_end, ?_previous_term_dissolved) AS ?previous_term_end)
          }
        }

        OPTIONAL { ?position pq:P4100 ?group . }
        OPTIONAL { ?position pq:P768 ?district . }

        SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
      }
      ORDER BY ASC(xsd:integer(SUBSTR(STR(?person), STRLEN("http://www.wikidata.org/entity/Q")+1)))
    SPARQL
  end
end

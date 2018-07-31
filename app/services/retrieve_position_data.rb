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
    query_format % { position_held_item:      position_held_item,
                     parliamentary_term_item: parliamentary_term_item,
                     person_bind:             person_bind, }
  end

  private

  def query_format
    <<~SPARQL
      SELECT DISTINCT
        ?person (GROUP_CONCAT(?merged_then_deleted) AS ?merged_then_deleted) ?revision
        ?position ?position_start ?position_start_precision
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
        # We want a unique value for the start of the term, which
        # might be with P571 (inception) or P580 (start time), so
        # prefer more precision to less, and inception to start time
        # using COALESCE:
        OPTIONAL { ?page_term p:P571 ?inception_s
          OPTIONAL { ?inception_s psv:P571 [wikibase:timeValue ?term_inception_day_precision; wikibase:timePrecision 11] }
          OPTIONAL { ?inception_s psv:P571 [wikibase:timeValue ?term_inception_month_precision; wikibase:timePrecision 10] }
          OPTIONAL { ?inception_s psv:P571 [wikibase:timeValue ?term_inception_year_precision; wikibase:timePrecision 9] }
        }
        OPTIONAL { ?page_term p:P580 ?start_time_s
          OPTIONAL { ?start_time_s psv:P580 [wikibase:timeValue ?term_start_time_day_precision; wikibase:timePrecision 11] }
          OPTIONAL { ?start_time_s psv:P580 [wikibase:timeValue ?term_start_time_month_precision; wikibase:timePrecision 10] }
          OPTIONAL { ?start_time_s psv:P580 [wikibase:timeValue ?term_start_time_year_precision; wikibase:timePrecision 9] }
        }
        BIND(
          COALESCE(
            ?term_inception_day_precision,
            ?term_start_time_day_precision,
            ?term_inception_month_precision,
            ?term_start_time_month_precision,
            ?term_inception_year_precision,
            ?term_start_time_year_precision
          ) AS ?term_start
        )
        OPTIONAL { ?position pq:P4100 ?group . }
        OPTIONAL { ?position pq:P768 ?district . }
        OPTIONAL { ?position pqv:P580 [wikibase:timeValue ?position_start; wikibase:timePrecision ?position_start_precision] . }
        OPTIONAL { ?merged_then_deleted owl:sameAs ?person }
        BIND(ceil((year(?term_start) - year(?position_start)) * 365.2425 +
                  (month(?term_start) - month(?position_start)) * 30.4375 +
                  (day(?term_start) - day(?position_start))) AS ?days_before_term_start)
        FILTER (!bound(?term) || ?term = ?page_term)
        FILTER (
          !bound(?term_start) || !bound(?position_start) ||
          (?position_start_precision = 9 && year(?term_start) <= year(?position_start)) ||
          (?position_start_precision = 10 && (
            year(?term_start) <= year(?position_start) ||
            (year(?term_start) = year(?position_start) && month(?term_start) <= month(?position_start))
          )) ||
          (?position_start_precision = 11 && ?days_before_term_start < 28)
        )
      }
      GROUP BY ?person ?revision ?position ?position_start ?position_start_precision ?term ?term_start ?group ?district
    SPARQL
  end

  def person_bind
    return '' unless person_item
    "BIND(wd:#{person_item} AS ?person)"
  end
end

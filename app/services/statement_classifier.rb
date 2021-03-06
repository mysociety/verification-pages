# frozen_string_literal: true

# Service to classify a statement based on if we can submit data to Wikidata or
# not.
class StatementClassifier
  def initialize(statement:, existing_statements:, items:)
    @statement = statement
    @existing_statements = existing_statements
    @items = items
  end

  def decorate
    StatementDecorator.new(@statement, comparison)
  end

  private

  def comparison
    MembershipComparison.new(
      existing:   existing_statements,
      suggestion: suggested_statement
    )
  end

  def existing_statements
    @existing_statements.each_with_object({}) do |data, memo|
      memo[data.position] = {
        position: data.position_held,
        start:    data.position_start,
        end:      data.position_end,
        term:     {
          id:    data.term,
          start: data.term_start,
          end:   data.term_end,
        },
        party:    { id: data.group },
        district: { id: data.district },
      }
    end
  end

  def suggested_statement
    suggested_positions.merge(
      term:     suggested_term,
      person:   suggested_person,
      party:    suggested_party,
      district: suggested_district
    ).merge(suggested_dates)
  end

  def suggested_positions
    {
      position:          @items[:position]&.item,
      position_parent:   @items[:position]&.parent,
      position_children: @items[:position]&.children&.map(&:item),
    }
  end

  def suggested_term
    {
      id:    @items[:term]&.term,
      start: @items[:term]&.start,
      end:   @items[:term]&.end,
      eopt:  @items[:term]&.previous_term_end,
      sont:  @items[:term]&.next_term_start,
    }
  end

  def suggested_person
    { disambiguation: @items[:person]&.disambiguation }
  end

  def suggested_party
    { id: @items[:group]&.item, disambiguation: @items[:group]&.disambiguation }
  end

  def suggested_district
    { id: @items[:district]&.item, disambiguation: @items[:district]&.disambiguation }
  end

  def suggested_dates
    {
      start: @statement.position_start,
      end:   @statement.position_end,
    }
  end
end

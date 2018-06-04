class StatementsStatistics
  def initialize(suggestion_store_url: 'https://suggestions-store.mysociety.org')
    @suggestion_store_url = suggestion_store_url
  end

  def statistics
    countries.map do |country|
      statements = JSON.parse(RestClient.get(country['export_json_url']))
      grouped_statements = statements.group_by { |s| s['position_item'] }
      position_stats = grouped_statements.map do |position, position_statements|
        PositionStatistics.new(
          position: position,
          statements: position_statements,
          existing_positions: existing_positions
        )
      end
      [country['code'], position_stats]
    end.to_h
  end

  private

  attr_reader :suggestion_store_url

  def countries
    JSON.parse(RestClient.get(URI.join(suggestion_store_url, '/export/countries.json').to_s))
  end

  def existing_positions
    return @position_to_page_titles if @position_to_page_titles
    # Make a Hash mapping from a position to a Set of associated page titles:
    @position_to_page_titles = Hash.new { |h, k| h[k] = Set.new }
    Page.pluck(:position_held_item, :title).inject(@position_to_page_titles) do |acc, (position, page_title)|
      acc[position].add(page_title)
      acc
    end
  end
end

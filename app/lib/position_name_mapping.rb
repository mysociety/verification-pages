# frozen_string_literal: true

class PositionNameMapping
  def initialize(positions:)
    @positions = positions.compact
  end

  def mapping
    wikidata_api_lookup(positions).map do |data|
      [data['id'], data.dig('labels', 'en', 'value') || 'no label']
    end.to_h
  end

  private

  attr_reader :positions

  def wikidata_api_lookup(items)
    items.each_slice(50).flat_map do |items_slice|
      url = wikidata_api_url + items_slice.join('|')
      JSON.parse(RestClient.get(url))['entities'].values
    end
  end

  def wikidata_api_url
    'https://www.wikidata.org/w/api.php?action=wbgetentities&format=json&ids='
  end
end

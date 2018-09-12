# frozen_string_literal: true

require 'suggestions_store/request'

module SuggestionsStore
  def self.countries
    Request.get('/export/countries.json').map do |country_data|
      Country.new(
        code:            country_data[:code],
        export_json_url: country_data[:export_json_url]
      )
    end
  end

  class Country
    attr_reader :code, :export_json_url

    def initialize(code:, export_json_url: nil)
      @code = code
      @export_json_url = export_json_url
    end

    def suggestions
      url = export_json_url || export_url
      get_suggestions(url)
    end

    def export_url(format: 'json')
      URI.join(Request::URL, "/export/#{code}.#{format}").to_s
    end

    private

    def get_suggestions(url)
      Request.get(url).map do |suggestion_data|
        Suggestion.new(suggestion_data)
      end
    end
  end

  class Suggestion < OpenStruct
    def verify!(data = {})
      Request.post("/suggestions/#{transaction_id}/verifications", data)
    end
  end
end

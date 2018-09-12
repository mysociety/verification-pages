# frozen_string_literal: true

require 'json'
require 'rest-client'

module SuggestionsStore
  class Request
    URL = ENV.fetch(
      'SUGGESTIONS_STORE_URL', 'https://suggestions-store.mysociety.org'
    )
    USERNAME = ENV['SUGGESTIONS_STORE_USERNAME']
    PASSWORD = ENV['SUGGESTIONS_STORE_PASSWORD']

    def self.get(path)
      uri = URI.join(base_uri, path)
      parse { RestClient.get(uri.to_s) }
    end

    def self.post(path, data)
      uri = URI.join(base_uri, path)
      parse { RestClient.post(uri.to_s, data) }
    end

    def self.base_uri
      URI.parse(URL).tap do |uri|
        uri.user = USERNAME
        uri.password = PASSWORD
      end
    end
    private_class_method :base_uri

    def self.parse(*)
      response = yield
      JSON.parse(response.body, symbolize_names: true) if response
    rescue RestClient::Exception => e
      raise "Suggestion store failed: #{e.message}"
    end
    private_class_method :parse
  end
end

# frozen_string_literal: true

# Module wrapping Wiki client calls
module WikiClient
  extend ActiveSupport::Concern

  WIKI_SITE = ENV.fetch('WIKIDATA_SITE')
  WIKI_USERNAME = ENV.fetch('WIKIDATA_USERNAME')
  WIKI_PASSWORD = ENV.fetch('WIKIDATA_PASSWORD')

  private

  def client
    @client ||= begin
      client = MediawikiApi::Client.new("https://#{WIKI_SITE}/w/api.php")

      result = client.log_in(WIKI_USERNAME, WIKI_PASSWORD)
      if result['result'] != 'Success'
        abort "MediawikiApi::Client#log_in failed: #{result}"
      end

      client
    end
  end
end

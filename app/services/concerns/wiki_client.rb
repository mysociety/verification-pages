# frozen_string_literal: true

# Module wrapping Wiki client calls
module WikiClient
  extend ActiveSupport::Concern

  private

  def client
    @client ||= begin
      client = MediawikiApi::Client.new("https://#{wiki_site}/w/api.php")

      result = client.log_in(wiki_username, wiki_password)
      if result['result'] != 'Success'
        abort "MediawikiApi::Client#log_in failed: #{result}"
      end

      client
    end
  end

  def wiki_site
    ENV.fetch('WIKIDATA_SITE')
  end

  def wiki_username
    ENV.fetch('WIKIDATA_USERNAME')
  end

  def wiki_password
    ENV.fetch('WIKIDATA_PASSWORD')
  end
end

require 'json'
require 'open-uri'
require 'rest-client'
require 'securerandom'

class IDMapper
  COLLECTION = :persons

  def fb_id_for(wikidata_id)
    existing_wd_to_fb_id[COLLECTION][wikidata_id]
  end

  def new_fb_id_for(facebook_id, wikidata_id, payload = {})
    payload = payload.merge(
      identifier_a: {
        scheme_id: SCHEMA_WIKIDATA.fetch(COLLECTION),
        value: wikidata_id,
      },
      identifier_b: {
        scheme_id: SCHEMA_FD_ID.fetch(COLLECTION),
        value: facebook_id,
      },
    ).to_json
    post_url = "#{ID_MAPPING_STORE_BASE_URL}/equivalence-claim"
    headers = { content_type: :json, accept: :json, x_api_key: api_key }
    response = RestClient.post post_url, payload, headers
    unless response.code == 201
      raise "Got an error response #{response.code} on posting #{payload} to #{post_url}"
    end
    # Update the existing store with the newly created ID before
    # returning it:
    existing_wd_to_fb_id[COLLECTION][wikidata_id] = facebook_id
    facebook_id
  end

  private

  def existing_wd_to_fb_id
    @existing_wd_to_fb_id ||= COLLECTIONS.map do |collection|
      [collection, existing_wd_to_fb_id_for(collection)]
    end.to_h
  end

  def existing_wd_to_fb_id_for(collection)
    url = "#{ID_MAPPING_STORE_BASE_URL}/scheme/#{SCHEMA_WIKIDATA.fetch(collection)}"
    data = JSON.parse(open(url, &:read))['results']
    data.map do |k, other_identifiers|
      [
        k,
        other_identifiers.find { |i| i['scheme_id'] == SCHEMA_FD_ID[collection] }&.fetch('value'),
      ]
    end.to_h
  end

  def api_key
    api_key_from_env = ENV['ID_MAPPING_API_KEY']
    unless api_key_from_env
      raise 'You must set the environment variable ID_MAPPING_API_KEY'
    end
    api_key_from_env
  end

  ID_MAPPING_STORE_BASE_URL = 'https://id-mapping-store.mysociety.org'

  COLLECTIONS = %i(persons).freeze

  SCHEMA_WIKIDATA = {
    persons: 1,
  }.freeze
  SCHEMA_FD_ID = {
    persons: 7,
  }.freeze
end

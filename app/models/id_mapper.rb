require 'json'
require 'open-uri'
require 'rest-client'
require 'securerandom'

class IDMapper
  def ms_uuid_for(collection, wikidata_id, comment_for_creation = '')
    existing = existing_wd_to_ms_uuid[collection][wikidata_id]
    return existing if existing
    new_ms_uuid_for(collection, wikidata_id, comment_for_creation)
  end

  private

  def new_ms_uuid_for(collection, wikidata_id, comment_for_creation)
    ms_uuid = "urn:uuid:#{SecureRandom.uuid}"
    payload = {
      identifier_a: {
        scheme_id: SCHEMA_WIKIDATA.fetch(collection),
        value: wikidata_id,
      },
      identifier_b: {
        scheme_id: SCHEMA_MS_UUID.fetch(collection),
        value: ms_uuid,
      },
      comment: comment_for_creation,
    }.to_json
    post_url = "#{ID_MAPPING_STORE_BASE_URL}/equivalence-claim"
    headers = { content_type: :json, accept: :json, x_api_key: api_key }
    response = RestClient.post post_url, payload, headers
    unless response.code == 201
      raise "Got an error response #{response.code} on posting #{payload} to #{post_url}"
    end
    # Update the existing store with the newly created ID before
    # returning it:
    existing_wd_to_ms_uuid[collection][wikidata_id] = ms_uuid
    ms_uuid
  end

  def existing_wd_to_ms_uuid
    @existing_wd_to_ms_uuid ||= COLLECTIONS.map do |collection|
      [collection, existing_wd_to_ms_uuid_for(collection)]
    end.to_h
  end

  def existing_wd_to_ms_uuid_for(collection)
    url = "#{ID_MAPPING_STORE_BASE_URL}/scheme/#{SCHEMA_WIKIDATA.fetch(collection)}"
    data = JSON.parse(open(url, &:read))['results']
    data.map do |k, other_identifiers|
      [
        k,
        other_identifiers.find { |i| i['scheme_id'] == SCHEMA_MS_UUID[collection] }&.fetch('value'),
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

  COLLECTIONS = %i(persons organizations memberships).freeze

  SCHEMA_WIKIDATA = {
    persons: 1,
    memberships: 2,
    organizations: 3,
  }.freeze
  SCHEMA_MS_UUID = {
    persons: 4,
    memberships: 5,
    organizations: 6,
  }.freeze
end

require 'mediawiki_api'

class MediaWikiApiController < ApplicationController
  skip_before_action :verify_authenticity_token

  def api_proxy
    unless ENV['API_PROXY'] && Integer(ENV['API_PROXY']) == 1
      error = 'API_PROXY=1 must be set in the environment to use the ' \
              'API proxy (Warning: not for use on public installations!)'
      return render(:json => {error: error})
    end
    action = api_data.delete(:action)
    return render(:json => {error: 'No action supplied'}) unless action
    api_data.delete(:token)
    unless TOKEN_REQUIRED_FOR_ACTION[action]
      api_data[:token_type] = false
    end
    response = client.action action, api_data
    render(:json => response.data)
  end

  private

  WIKIDATA_USERNAME = ENV['WIKIDATA_USERNAME']
  WIKIDATA_PASSWORD = ENV['WIKIDATA_PASSWORD']
  WIKIDATA_SITE = ENV['WIKIDATA_SITE']

  def client
    if WIKIDATA_USERNAME.to_s.empty? || WIKIDATA_PASSWORD.to_s.empty?
      raise "Please set WIKIDATA_USERNAME and WIKIDATA_PASSWORD"
    end
    @client ||= MediawikiApi::Client.new("https://#{WIKIDATA_SITE}/w/api.php").tap do |c|
      result = c.log_in(WIKIDATA_USERNAME, WIKIDATA_PASSWORD)
      unless result['result'] == 'Success'
        raise "MediawikiApi::Client#log_in failed: #{result}"
      end
    end
  end

  TOKEN_REQUIRED_FOR_ACTION = {
    'wbsetreference' => true,
    'wbsetqualifier' => true,
    'wbcreateclaim' => true,
  }

  def api_data
    data = params.require(:data)
    if data[:action] == 'wbsearchentities'
      data.permit(:action, :search, :language, :limit, :type, :format)
    elsif data[:action] == 'wbgetentities'
      data.permit(:action, :props, :titles, :sites)
    elsif data[:action] == 'query'
      data.permit(:action, :prop, :titles)
    elsif data[:action] == 'wbsetreference'
      data.permit(:action, :statement, :snaks, :baserevid)
    elsif data[:action] == 'wbsetqualifier'
      data.permit(:action, :claim, :property, :value, :baserevisionid, :snaktype)
    elsif data[:action] == 'wbcreateclaim'
      data.permit(:action, :entity, :snaktype, :property, :value, :baserevid)
    elsif data[:action] == 'wbgetclaims'
      data.permit(:action, :entity, :claim)
    elsif data[:action] == 'wbeditentity'
      data.permit(:action, :new, :data)
    else
      raise "Unknown action: #{data[:action]}"
    end.to_h
  end
end

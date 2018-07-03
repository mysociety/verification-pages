require 'mediawiki_api'

class MediaWikiApiController < ApplicationController
  skip_before_action :verify_authenticity_token

  def api_proxy
    unless ENV['API_PROXY'] && Integer(ENV['API_PROXY']) == 1
      error = 'API_PROXY=1 must be set in the environment to use the ' \
              'API proxy (Warning: not for use on public installations!)'
      return render(:json => {error: error})
    end
    action = params[:action_name]
    return render(:json => {error: 'No action supplied'}) unless action
    api_data = api_data_for_action(action)
    api_data[:token_type] = false unless TOKEN_REQUIRED_FOR_ACTION[action]
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
    'wbeditentity' => true
  }

  def api_data_for_action(action)
    if action == 'wbsearchentities'
      params.permit(:search, :language, :limit, :type)
    elsif action == 'wbgetentities'
      params.permit(:props, :titles, :sites)
    elsif action == 'query'
      params.permit(:prop, :titles)
    elsif action == 'wbsetreference'
      params.permit(:statement, :snaks, :baserevid)
    elsif action == 'wbsetqualifier'
      params.permit(:claim, :property, :value, :baserevisionid, :snaktype)
    elsif action == 'wbcreateclaim'
      params.permit(:entity, :snaktype, :property, :value, :baserevid)
    elsif action == 'wbgetclaims'
      params.permit(:entity, :claim)
    elsif action == 'wbeditentity'
      params.permit(:new, :data)
    else
      raise "Unknown action: #{action}"
    end.to_h
  end
end

# frozen_string_literal: true

require 'mediawiki/client'
require 'mediawiki/page'

class WikiPageTemplateTag
  include WikiClient

  def initialize(wiki_page_title)
    @wiki_page_title = wiki_page_title
  end

  def page_attributes
    {
      country:                 country,
      position_held_item:      params[:position_held_item],
      parliamentary_term_item: params[:parliamentary_term_item],
      csv_source_url:          params[:csv_source_url],
    }
  end

  def update_page(content)
    section.replace_output(content, 'Created or updated verification page')
  end

  def wikidata_url
    "https://#{wiki_site}/wiki/#{wiki_page_title}"
  end

  private

  attr_reader :wiki_page_title

  def country
    @country ||= Country.find_by(code: params[:country_code])
  end

  def params
    section.params
  end

  def section
    @section ||= MediaWiki::Page::ReplaceableContent.new(
      client:   mediawiki_client,
      title:    wiki_page_title,
      template: wiki_template_name
    )
  end

  def mediawiki_client
    @mediawiki_client ||= MediaWiki::Client.new(
      site:     wiki_site,
      username: wiki_username,
      password: wiki_password
    )
  end

  def wiki_template_name
    ENV.fetch('WIKI_TEMPLATE_NAME', 'Verification_page')
  end
end

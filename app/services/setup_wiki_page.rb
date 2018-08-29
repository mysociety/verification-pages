# frozen_string_literal: true

class SetupWikiPage < ServiceBase
  Error = Class.new(StandardError)

  include WikiClient

  def initialize(wiki_page_title)
    @wiki_page_title = wiki_page_title
  end

  def run
    page = Page.find_or_initialize_by(title: wiki_page_title)
    page.assign_attributes(
      country:            country,
      position_held_item: settings[:position_held_item],
      parliamentary_term_item: settings[:parliamentary_term_item],
      csv_source_url:     settings[:csv_source_url]
    )

    raise Error, "Couldn't save the page" unless page.save

    LoadStatements.run(page.title)
    UpdateVerificationPage.run(page.title)
  end

  def redirect_url
    "https://#{wiki_site}/wiki/#{wiki_page_title}"
  end

  private

  attr_reader :wiki_page_title

  def country
    @country ||= Country.find_by(code: settings[:country_code])
  end

  def settings
    @settings ||= JSON.parse(settings_json, symbolize_names: true)
  end

  def settings_json
    @settings_json ||= client.get_wikitext(settings_json_title).body
  end

  def settings_json_title
    wiki_page_title + '/settings.json'
  end
end

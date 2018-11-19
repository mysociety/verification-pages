# frozen_string_literal: true

# Service object to update MediaWiki page source
class UpdateWikidataPage < ServiceBase
  include WikiClient

  attr_reader :page_title, :page_content

  def initialize(page_title, page_content)
    @page_title = page_title
    @page_content = page_content
  end

  def run
    client.create_page(page_title, page_content)
  end
end

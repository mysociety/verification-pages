# frozen_string_literal: true

# Service object to update MediaWiki page source
class UpdateVerificationPage < ServiceBase
  attr_reader :page_title

  def initialize(page_title)
    @page_title = page_title
  end

  def run
    UpdateWikidataPage.run(page_title, page_content)
  end

  private

  def page_content
    @page_content ||= GenerateVerificationPage.run(page_title)
  end
end

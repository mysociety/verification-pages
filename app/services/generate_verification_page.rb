# frozen_string_literal: true

# Service object to generate MediaWiki page source
class GenerateVerificationPage < ServiceBase
  include Renderer

  attr_reader :page

  def initialize(page_title)
    @page = Page.find_by!(title: page_title)
  end

  def run
    render template, page: page, statements: classify_page.statements
  end

  private

  def classify_page
    @classify_page ||= PageClassifier.new(page.title)
  end

  def template
    Rails.root.join('app', 'views', 'wiki', 'verification.mediawiki.erb')
  end
end

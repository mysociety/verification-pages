# frozen_string_literal: true

# Service object to update MediaWiki templates source
class UpdateVerificationTemplates < ServiceBase
  include Renderer
  include WikiClient

  attr_reader :page_title

  def initialize(page_title)
    @page_title = page_title
  end

  def run
    templates.each do |template|
      template_name = "#{page_title}/#{template.basename('.mediawiki.erb')}"
      print "Updating #{template_name}... "
      client.create_page(template_name, render(template))
    rescue MediawikiApi::ApiError => ex
      puts "error (#{ex.message})"
    else
      puts 'done'
    end
  end

  private

  def templates
    Rails.root.join('app', 'views', 'wiki', 'verification').glob('*.mediawiki.erb')
  end
end

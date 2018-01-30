# frozen_string_literal: true

# Service object to update MediaWiki javascript source
class UpdateVerificationJavascript < ServiceBase
  include WikiClient

  attr_reader :page_title

  def initialize(page_title)
    @page_title = page_title
  end

  def run
    begin
      print "Updating #{page_title}... "
      client.create_page(page_title, source.read)
    rescue MediawikiApi::ApiError => ex
      puts "... error (#{ex.message})"
    else
      puts 'done'
    end
  end

  private

  def source
    Rails.root.join('app', 'assets', 'javascripts', 'verification.js')
  end
end

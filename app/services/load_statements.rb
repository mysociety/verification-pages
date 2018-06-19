class LoadStatements < ServiceBase
  attr_reader :page

  def initialize(page_title)
    @page = Page.find_by!(title: page_title)
  end

  def run
    json.map do |result|
      statement = Statement.find_or_initialize_by(
        transaction_id: result[:transaction_id]
      )

      statement.update_attributes(
        page: page,
        person_name: result[:person_name],
        electoral_district_name: result[:electoral_district_name],
        electoral_district_item: result[:electoral_district_item],
        fb_identifier: result[:fb_identifier]
      )
    end
  end

  private

  def json
    @json ||= JSON.parse(raw_data, symbolize_names: true)
  end

  def raw_data
    uri = URI(ENV.fetch('SUGGESTIONS_STORE_URL'))
    uri.path = "/export/#{page.country.code.upcase}/#{page.position_held_item}.json"
    RestClient.get(uri.to_s)
  rescue RestClient::Exception => e
    raise "Suggestion store failed: #{e.message}"
  end
end

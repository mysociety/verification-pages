class LoadStatements < ServiceBase
  attr_reader :page

  def initialize(page_title)
    @page = Page.find_by!(title: page_title)
  end

  def run
    json.map do |result|
      Statement.create_with(
        parliamentary_group_item: result[:parliamentary_group_identifier],
        electoral_district_item: result[:electoral_district_identifier],
        parliamentary_term_item: page.parliamentary_term_item
      ).find_or_create_by(
        transaction_id: result[:transaction_id],
        person_item: result[:person_identifier]
      )
    end
  end

  private

  def params
    @params ||= RetrieveCountryPosition.run(page.position_held_item)
  end

  def json
    @json ||= JSON.parse(raw_data, symbolize_names: true)
  end

  def raw_data
    uri = URI(ENV.fetch('SUGGESTIONS_STORE_URL'))
    uri.path = "/export/#{params.country}/#{params.position}.json"
    RestClient.get(uri.to_s)
  rescue RestClient::Exception => e
    raise "Suggestion store failed: #{e.message}"
  end
end

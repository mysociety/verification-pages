require 'csv'
require 'digest'

class LoadStatements < ServiceBase
  attr_reader :page

  def initialize(page_title)
    @page = Page.find_by!(title: page_title)
  end

  def run
    csv.map do |result|
      result[:transaction_id] ||= generate_transaction_id(result)

      statement = Statement.find_or_initialize_by(
        transaction_id: result[:transaction_id]
      )

      statement.update_attributes!(
        page: page,
        person_name: result[:person_name],
        person_item: result[:person_item],
        electoral_district_name: result[:electoral_district_name],
        electoral_district_item: result[:electoral_district_item],
        fb_identifier: result[:fb_identifier]
      )
    end
  end

  private

  def csv
    @csv ||= CSV.parse(raw_data, headers: true, header_converters: :symbol,
                                 converters: nil)
  end

  def raw_data
    RestClient.get(page.csv_source_url).body
  rescue RestClient::Exception => e
    raise "Suggestion store failed: #{e.message}"
  end

  def generate_transaction_id(result)
    pairs = result.to_h.merge(country: page.country.code).sort

    transation_string = pairs.each_with_object([]) do |(k, v), a|
      a << "#{k}:#{v}"
    end.join(';')

    'md5:' + Digest::MD5.hexdigest(transation_string)
  end
end

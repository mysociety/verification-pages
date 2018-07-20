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

      # We need to be careful not wipe out any manually reconciled
      # items when refreshing from the upstream CSV file, so don't
      # overwrite the *_item attributes if that'd make them blank:
      %i[person_item electoral_district_item parliamentary_group_item].each do |item_attribute|
        if result[item_attribute].present?
          statement.public_send("#{item_attribute}=", result[item_attribute])
        end
      end
      # The other attributes we always update from the upstream CSV:
      statement.update_attributes!(
        page: page,
        person_name: result[:person_name],
        electoral_district_name: result[:electoral_district_name],
        parliamentary_group_name: result[:parliamentary_group_name],
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

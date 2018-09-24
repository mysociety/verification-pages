# frozen_string_literal: true

class Page
  module TransactionID
    def generate_transaction_id(data)
      pairs = data.merge(country: country.code).sort

      transation_string = pairs.each_with_object([]) do |(k, v), a|
        a << "#{k}:#{v}"
      end.join(';')

      'md5:' + Digest::MD5.hexdigest(transation_string)
    end
  end
end

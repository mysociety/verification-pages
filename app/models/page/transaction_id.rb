# frozen_string_literal: true

class Page
  module TransactionID
    UnknownHashEpochError = Class.new(StandardError)

    def generate_transaction_id(data)
      hash(data.merge(hash_data))
    end

    private

    def hash_data
      # These hashes should not be modified. it will change existing transaction
      # IDs resulting in duplicate Statements being created when page CSV
      # sources are next fetched
      case hash_epoch
      when 1 then { country: country.code }
      else raise UnknownHashEpochError
      end
    end

    def hash(pairs)
      transation_string = pairs.sort.each_with_object([]) do |(k, v), a|
        a << "#{k}:#{v}"
      end.join(';')

      'md5:' + Digest::MD5.hexdigest(transation_string)
    end
  end
end

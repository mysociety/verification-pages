# frozen_string_literal: true

# Object representing the result of a SPARQL query
class SparqlResult
  def initialize(raw_hash, variables)
    @raw = raw_hash
    @variables = variables
  end

  private

  def respond_to_missing?(*args)
    super
  end

  def method_missing(attr)
    return super unless @variables.include?(attr.to_s)

    h = @raw[attr]
    return nil unless h

    map_value(h, attr)
  end

  def partial_date_value(h, attr)
    s = h[:value][0...10]
    precision = @raw.dig(:"#{attr}_precision", :value) || '11'
    return s if precision == '11'
    return s[0...7] if precision == '10'
    return s[0...4] if precision == '9'
    raise "Unknown precision #{precision} for attribute #{attr}"
  end

  def map_value(h, attr)
    return partial_date_value(h, attr) if h[:datatype] == 'http://www.w3.org/2001/XMLSchema#dateTime'

    return h[:value].to_s.split('/').last if h[:type] == 'uri'

    h[:value]
  end
end

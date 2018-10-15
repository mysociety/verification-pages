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

  def method_missing(attr, *args)
    return super unless @variables.include?(attr.to_s)

    h = @raw[attr]
    return nil unless h

    map_value(h)
  end

  def map_value(h)
    return h[:value].to_s[0..9] if h[:datatype] == 'http://www.w3.org/2001/XMLSchema#dateTime'

    return h[:value].to_s.split('/').last if h[:type] == 'uri'

    h[:value]
  end
end

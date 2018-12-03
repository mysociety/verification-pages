# frozen_string_literal: true

# Module with convenience methods for accessing and mapping results of
# difference data types from data returned from a SPARQL query
module SparqlResult
  attr_writer :variables

  DATATYPE_BOOLEAN = 'http://www.w3.org/2001/XMLSchema#boolean'
  DATATYPE_DATETIME = 'http://www.w3.org/2001/XMLSchema#dateTime'

  def [](*args)
    value = super

    return map_hash(value) if value.is_a?(Hash)
    return extend_array(value) if value.is_a?(Array)

    value
  end

  def datatype(attr)
    value = fetch(attr, {})
    value[:datatype] if value.is_a?(Hash)
  end

  private

  def variables
    (@variables || []).map(&:to_sym) | keys
  end

  def respond_to_missing?(*args)
    super
  end

  def method_missing(attr, *args)
    bool_attr = attr[/(.*?)\??$/, 1].to_sym

    return self[bool_attr] if datatype(bool_attr) == DATATYPE_BOOLEAN
    return super unless variables.include?(attr)

    self[attr]
  end

  def map_hash(hash)
    return hash[:value] == 'true' if hash[:datatype] == DATATYPE_BOOLEAN
    return hash[:value].to_s[0..9] if hash[:datatype] == DATATYPE_DATETIME
    return hash[:value].to_s.split('/').last if hash[:type] == 'uri'

    hash[:value]
  end

  def extend_array(array)
    array.map { |item| item.extend(SparqlResult) }
  end
end

# frozen_string_literal: true

# Module with convenience methods for accessing and mapping results of
# difference data types from data returned from a SPARQL query
module SparqlResult
  attr_writer :variables

  DATATYPE_BOOLEAN = 'http://www.w3.org/2001/XMLSchema#boolean'
  DATATYPE_DATETIME = 'http://www.w3.org/2001/XMLSchema#dateTime'

  def [](*args)
    value = super
    return nil unless value
    map_value(value)
  end

  def datatype(attr)
    fetch(attr, {})[:datatype]
  end

  private

  def variables
    @variables || keys
  end

  def respond_to_missing?(*args)
    super
  end

  def method_missing(attr, *args)
    bool_attr = attr.to_s.match(/(.*?)\??$/)[1].to_sym
    datatype = fetch(bool_attr, {})[:datatype]
    return self[bool_attr] if datatype == DATATYPE_BOOLEAN

    return super unless variables.include?(attr.to_s)
    self[attr]
  end

  def map_value(h)
    return h[:value] == 'true' if h[:datatype] == DATATYPE_BOOLEAN
    return h[:value].to_s[0..9] if h[:datatype] == DATATYPE_DATETIME
    return h[:value].to_s.split('/').last if h[:type] == 'uri'

    h[:value]
  end
end

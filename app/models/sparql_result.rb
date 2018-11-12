# frozen_string_literal: true

# Module with convenience methods for accessing and mapping results of
# difference data types from data returned from a SPARQL query
module SparqlResult
  attr_writer :variables

  DATATYPE_DATETIME = 'http://www.w3.org/2001/XMLSchema#dateTime'

  def [](*args)
    value = super
    return nil unless value
    map_value(value)
  end

  private

  def variables
    @variables || keys
  end

  def respond_to_missing?(*args)
    super
  end

  def method_missing(attr, *args)
    return super unless variables.include?(attr.to_s)
    self[attr]
  end

  def map_value(h)
    return h[:value].to_s[0..9] if h[:datatype] == DATATYPE_DATETIME
    return h[:value].to_s.split('/').last if h[:type] == 'uri'

    h[:value]
  end
end

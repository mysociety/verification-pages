# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SparqlResult, type: :model do
  let(:variables) { %w[string datetime item missing] }
  let(:json) do
    <<~JSON
      {
        "string": {
          "value": "ABC"
        },
        "datetime": {
          "datatype": "http://www.w3.org/2001/XMLSchema#dateTime",
          "type": "literal",
          "value": "2018-01-01T00:00:00Z"
        },
        "item": {
          "type": "uri",
          "value": "http://www.wikidata.org/entity/Q1"
        }
      }
    JSON
  end
  let(:result) do
    SparqlResult.new(JSON.parse(json, symbolize_names: true), variables)
  end

  it 'can return literal values' do
    expect(result.string).to eq 'ABC'
  end

  it 'can return datetime values' do
    expect(result.datetime).to eq '2018-01-01'
  end

  it 'can return item URI values' do
    expect(result.item).to eq 'Q1'
  end

  it 'should return nil for missing values' do
    expect(result.missing).to be_nil
  end

  it 'will raise NoMethodError for other methods' do
    expect { result.other }.to raise_error(NoMethodError)
  end
end

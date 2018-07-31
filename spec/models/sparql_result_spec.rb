# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SparqlResult, type: :model do
  let(:variables) { %w[string datetime item missing partial_date partial_date_precision] }
  let(:precision) { '11' }
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
        },
        "partial_date": {
          "datatype": "http://www.w3.org/2001/XMLSchema#dateTime",
          "type": "literal",
          "value": "1988-12-24T00:00:00Z"
        },
        "partial_date_precision": {
          "datatype": "http://www.w3.org/2001/XMLSchema#dateTime",
          "type": "literal",
          "value": "#{precision}"
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

  it 'can return a date specified as full date precision' do
    expect(result.partial_date).to eq '1988-12-24'
  end

  context 'a date only has month precision' do
    let(:precision) { 10 }
    it 'should return just the year and the month' do
      expect(result.partial_date).to eq '1988-12'
    end
  end

  context 'a date only has month precision' do
    let(:precision) { 9 }
    it 'should return just the year and the month' do
      expect(result.partial_date).to eq '1988'
    end
  end

  context 'an unsupported value for precision' do
    let(:precision) { 12 }
    it 'should raise an exception' do
      expect { result.partial_date }.to raise_error('Unknown precision 12 for attribute partial_date')
    end
  end
end

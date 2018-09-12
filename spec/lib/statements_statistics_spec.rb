# frozen_string_literal: true

require 'rails_helper'

describe StatementsStatistics do
  describe '#statistics' do
    let! (:page) { create(:page, position_held_item: 'Q15964890') }

    before do
      ENV['SUGGESTIONS_STORE_URL'] = 'http://suggestions-store'
      stub_request(:get, 'http://suggestions-store/export/countries.json')
        .to_return(body: '[{"code": "ca", "export_json_url": "http://suggestions-store/export/ca.json"}]')
      body = [
        {
          id:                  1,
          verification_status: 'correct',
          position_item:       'Q15964890',
        },
        {
          id:                  2,
          verification_status: 'correct',
          position_item:       'Q15964890',
        },
        {
          id:                  3,
          verification_status: 'incorrect',
          position_item:       'Q15964890',
        },
        {
          id:                  4,
          verification_status: 'invalid',
        },
      ]
      stub_request(:get, 'http://suggestions-store/export/ca.json')
        .to_return(body: JSON.generate(body))
    end

    it 'returns a hash of country stats' do
      statement_statistics = StatementsStatistics.new
      statistics = statement_statistics.statistics['ca']

      invalid_statement = statistics.last.first
      expect(invalid_statement['id']).to eq(4)
      expect(invalid_statement['verification_status']).to eq('invalid')

      position_stats = statistics.first.first
      expect(position_stats.position).to eq('Q15964890')
      expect(position_stats.correct).to eq(2)
      expect(position_stats.incorrect).to eq(1)
      expect(position_stats.unchecked).to eq(0)
      expect(position_stats.pages).to eq([page.title])
    end
  end
end

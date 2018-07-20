require 'rails_helper'

describe StatementsStatistics do
  describe '#statistics' do
    let! (:page) { create(:page, position_held_item: 'Q15964890') }
    before do
      stub_request(:get, 'https://suggestions-store.mysociety.org/export/countries.json')
        .to_return(body: '[{"code": "ca", "export_json_url": "https://suggestions-store.mysociety.org/export/ca.json"}]')
      body = [
        {
          id: 1,
          verification_status: 'correct',
          position_item: 'Q15964890'
        },
        {
          id: 2,
          verification_status: 'correct',
          position_item: 'Q15964890'
        },
        {
          id: 3,
          verification_status: 'incorrect',
          position_item: 'Q15964890'
        }
      ]
      stub_request(:get, 'https://suggestions-store.mysociety.org/export/ca.json')
        .to_return(body: JSON.generate(body))
    end
    it 'returns a hash of country stats' do
      statement_statistics = StatementsStatistics.new
      position_stats = statement_statistics.statistics['ca'].first
      expect(position_stats.position).to eq('Q15964890')
      expect(position_stats.correct).to eq(2)
      expect(position_stats.incorrect).to eq(1)
      expect(position_stats.unchecked).to eq(0)
      expect(position_stats.pages).to eq([page.title])
    end
  end
end

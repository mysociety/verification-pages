# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RetrieveItems, type: :service do
  let(:service) { RetrieveItems.new('Q1', 'Q2') }

  describe 'initialisation' do
    it 'assigns items instance variable' do
      expect(service.items).to eq %w[Q1 Q2]
    end
  end

  describe '#run' do
    it 'calls run_query with substituted items values' do
      allow(service).to receive(:query_format).and_return('%<items>s')
      expect(service).to receive(:run_query).with('(wd:Q1) (wd:Q2)').and_return([])
      service.run
    end

    it 'returns hash with item and labels' do
      allow(service).to receive(:run_query).and_return(
        [
          OpenStruct.new(item: 'Q1', label: 'Universe'),
          OpenStruct.new(item: 'Q2', label: 'Earth'),
        ]
      )
      expect(service.run).to eq('Q1' => 'Universe', 'Q2' => 'Earth')
    end

    context 'with invalid items' do
      let(:service) { RetrieveItems.new('Q1', 'abc', '', nil) }

      it 'ignores invalid items' do
        allow(service).to receive(:query_format).and_return('%<items>s')
        expect(service).to receive(:run_query).with('(wd:Q1)').and_return([])
        service.run
      end
    end
  end
end

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
      q1 = { item: 'Q1', label: 'Universe' }
      q2 = { item: 'Q2', label: 'Earth' }
      allow(service).to receive(:run_query).and_return([q1, q2])
      expect(service.run).to eq('Q1' => q1, 'Q2' => q2)
    end

    context 'with invalid items' do
      let(:service) { RetrieveItems.new('Q1', 'abc', '', nil) }

      it 'ignores invalid items' do
        allow(service).to receive(:query_format).and_return('%<items>s')
        expect(service).to receive(:run_query).with('(wd:Q1)').and_return([])
        service.run
      end
    end

    context 'with subclasses' do
      let(:service) { RetrieveItems.new('Q1') } # not Universe

      it 'combines into an array' do
        p3 = { item: 'Q1', child: 'Q2', child_label: 'Earth' }
        p4 = { item: 'Q1', child: 'Q111', child_label: 'Mars' }
        allow(service).to receive(:run_query).and_return([p3, p4])

        expect(service.run).to eq(
          'Q1' => { item: 'Q1', children: [
            { item: 'Q2', label: 'Earth' },
            { item: 'Q111', label: 'Mars' },
          ], }
        )
      end

      it 'ignores blank subclass items' do
        allow(service).to receive(:run_query).and_return(
          [{ item: 'Q1', child: nil, child_label: nil }]
        )

        expect(service.run).to eq('Q1' => { item: 'Q1', children: [] })
      end
    end
  end
end

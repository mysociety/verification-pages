# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RetrievePositionData, type: :service do
  let(:service) { RetrievePositionData.new('Q1', 'Q2') }

  describe 'initialisation' do
    it 'assigns position_held_items instance variable' do
      expect(service.position_held_items).to match_array(['Q1'])
    end

    it 'assigns person_item instance variable' do
      expect(service.person_item).to eq 'Q2'
    end

    context 'with more than one position_held_item' do
      let(:service) { RetrievePositionData.new(%w[Q1 Q2]) }

      it 'assigns position_held_items instance variable' do
        expect(service.position_held_items).to match_array(%w[Q1 Q2])
      end
    end
  end

  describe '#run' do
    it 'calls run_query with substituted position_held_items' do
      allow(service).to receive(:query_format).and_return('%<position_held_items>s')
      expect(service).to receive(:run_query).with('(wd:Q1)')
      service.run
    end

    context 'with person_item' do
      it 'calls run_query with substituted person_bind' do
        allow(service).to receive(:query_format).and_return('%<person_bind>s')
        expect(service).to receive(:run_query).with('BIND(wd:Q2 AS ?person)')
        service.run
      end
    end

    context 'without person_item' do
      let(:service) { RetrievePositionData.new('Q1') }

      it 'calls run_query with no person_bind' do
        allow(service).to receive(:query_format).and_return('%<person_bind>s')
        expect(service).to receive(:run_query).with('')
        service.run
      end
    end
  end
end

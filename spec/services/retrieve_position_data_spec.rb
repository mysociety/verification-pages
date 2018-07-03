# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RetrievePositionData, type: :service do
  let(:service) { RetrievePositionData.new('Q1', 'Q2', 'Q3') }

  describe 'initialisation' do
    it 'assigns position_held_item instance variable' do
      expect(service.position_held_item).to eq 'Q1'
    end

    it 'assigns parliamentary_term_item instance variable' do
      expect(service.parliamentary_term_item).to eq 'Q2'
    end

    it 'assigns person_item instance variable' do
      expect(service.person_item).to eq 'Q3'
    end
  end

  describe '#run' do
    it 'calls run_query with substituted position_held_item' do
      allow(service).to receive(:query_format).and_return('%<position_held_item>s')
      expect(service).to receive(:run_query).with('Q1')
      service.run
    end

    it 'calls run_query with substituted parliamentary_term_item' do
      allow(service).to receive(:query_format).and_return('%<parliamentary_term_item>s')
      expect(service).to receive(:run_query).with('Q2')
      service.run
    end

    context 'with person_item' do
      it 'calls run_query with substituted person_bind' do
        allow(service).to receive(:query_format).and_return('%<person_bind>s')
        expect(service).to receive(:run_query).with('BIND(wd:Q3 AS ?person)')
        service.run
      end
    end

    context 'without person_item' do
      let(:service) { RetrievePositionData.new('Q1', 'Q2') }

      it 'calls run_query with no person_bind' do
        allow(service).to receive(:query_format).and_return('%<person_bind>s')
        expect(service).to receive(:run_query).with('')
        service.run
      end
    end
  end
end

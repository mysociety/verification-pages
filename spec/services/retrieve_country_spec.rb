# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RetrieveCountry, type: :service do
  let(:service) { RetrieveCountry.new('Q1', 'Q2') }

  describe 'initialisation' do
    it 'assigns position_held_item instance variable' do
      expect(service.position_held_item).to eq 'Q1'
    end

    it 'assigns parliamentary_term_item instance variable' do
      expect(service.parliamentary_term_item).to eq 'Q2'
    end
  end

  describe '#run' do
    it 'calls run_query with substituted position_held_item' do
      allow(service).to receive(:query_format).and_return('%<position_held_item>s')
      expect(service).to receive(:run_query).with('Q1').and_return([])
      service.run
    end

    it 'calls run_query with substituted parliamentary_term_item' do
      allow(service).to receive(:query_format).and_return('%<parliamentary_term_item>s')
      expect(service).to receive(:run_query).with('Q2').and_return([])
      service.run
    end

    it 'returns the first result' do
      first = double('SPARQL result')
      expect(service).to receive(:run_query).and_return([first])
      expect(service.run).to eq first
    end
  end
end

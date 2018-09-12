# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RetrievePageData, type: :service do
  let(:service) { RetrievePageData.new('Q1', 'Q2') }

  describe 'initialisation' do
    it 'assigns position instance variable' do
      expect(service.position).to eq 'Q1'
    end

    it 'assigns term instance variable' do
      expect(service.term).to eq 'Q2'
    end
  end

  describe '#run' do
    it 'calls run_query with substituted position' do
      allow(service).to receive(:query_format).and_return('%<position>s')
      expect(service).to receive(:run_query).with('Q1').and_return([])
      service.run
    end

    it 'calls run_query with substituted term' do
      allow(service).to receive(:query_format).and_return('%<term>s')
      expect(service).to receive(:run_query).with('Q2').and_return([])
      service.run
    end

    it 'returns the first result' do
      allow(service).to receive(:run_query).and_return(%w[foo bar])
      expect(service.run).to eq 'foo'
    end
  end
end

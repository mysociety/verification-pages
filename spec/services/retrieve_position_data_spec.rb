# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RetrievePositionData, type: :service do
  let(:service) { RetrievePositionData.new('Q1') }

  describe 'initialisation' do
    it 'assigns position_held_item instance variable' do
      expect(service.position_held_item).to eq 'Q1'
    end
  end

  describe '#run' do
    it 'calls run_query with substituted position_held_item' do
      allow(service).to receive(:query).and_return('%<position_held_item>s')
      expect(service).to receive(:run_query).with('Q1')
      service.run
    end
  end
end

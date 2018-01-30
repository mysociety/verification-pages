# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResultsController, type: :controller do
  describe 'POST #create' do
    let(:statement) { double(:statement).as_null_object }

    it 'finds statement from ID' do
      expect(Statement).to receive(:find).with('1').and_return(statement)
      post :create, params: { id: '1' }
    end

    it 'calls update_result on statement' do
      result_params = {
        object: 'a', property: 'b', qualifier_p2937: 'c', qualifier_p4100: 'd',
        qualifier_p768: 'e', statement: 'f', subject: 'g', user: 'h', value: 'i'
      }
      allow(Statement).to receive(:find).with('1').and_return(statement)
      expect(statement).to receive(:update_result)
      post :create, params: result_params.merge(id: '1')
    end
  end
end

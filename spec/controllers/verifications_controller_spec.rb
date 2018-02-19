# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VerificationsController, type: :controller do
  describe 'POST #create' do
    let(:statement) { double(:statement).as_null_object }

    it 'finds statement from transaction ID' do
      expect(Statement).to receive(:find_by).with(transaction_id: '1').and_return(statement)
      post :create, params: { id: '1' }
    end

    it 'calls create_verification! on statement' do
      verification_params = { user: 'Bilbo', status: 'true' }
      allow(Statement).to receive(:find_by).with(transaction_id: '1').and_return(statement)
      expect(statement).to receive(:create_verification!)
      post :create, params: verification_params.merge(id: '1')
    end
  end
end

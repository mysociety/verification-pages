require 'rails_helper'

RSpec.describe StatementsController, type: :controller do
  include ActiveSupport::Testing::TimeHelpers

  let!(:statement) { create(:statement) }

  let(:show_parameters) do
    { id: '123', format: 'json' }
  end

  describe "GET #show" do{id: '123', format: 'json'}
    it 'returns http success for a transaction that exists' do
      get :show, params: show_parameters
      expect(response).to be_successful
    end

    it 'does not update the actioned_at time' do
      get :show, params: show_parameters
      expect(statement.actioned_at).to be_nil
    end

    context 'when force_type: done is provided' do
      let!(:show_parameters) do
        { id: '123', format: 'json', force_type: 'done' }
      end

      it 'should set actioned_at to a current timestamp' do
        travel_to Time.zone.local(2017, 11, 24, 01, 04, 44) do
          get :show, params: show_parameters
          statement.reload
          expect(statement.actioned_at).to eq(DateTime.new(2017, 11, 24, 01, 04, 44))
        end
      end
    end
  end
end

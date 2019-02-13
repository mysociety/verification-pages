# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatementsController, type: :controller do
  let!(:statement) { build(:statement) }

  let(:show_parameters) do
    { id: '123', format: 'json' }
  end

  before do
    allow(Page).to receive(:find_by!).with(title: statement.page.title)
                                     .and_return(statement.page)
    allow(Statement).to receive(:find_by!).with(transaction_id: '123')
                                          .and_return(statement)
  end

  describe 'GET #show' do
    it 'returns http success for a transaction that exists' do
      get :show, params: show_parameters
      expect(response).to be_successful
    end

    it 'does not update the actioned_at time' do
      get :show, params: show_parameters
      expect(statement.actioned_at).to be_nil
    end

    context 'when force_type: done is provided' do
      let(:show_parameters) do
        { id: '123', format: 'json', force_type: 'done' }
      end

      it 'should call record_actioned! on statement' do
        expect(statement).to receive(:record_actioned!)
        get :show, params: show_parameters
      end
    end

    context 'when force_type: manually_actionable is provided' do
      let(:show_parameters) do
        { id: '123', format: 'json', force_type: 'manually_actionable',
          error_message: 'Error', }
      end

      it 'should call report_error!! on statement' do
        expect(statement).to receive(:report_error!).with('Error')
        get :show, params: show_parameters
      end
    end

    context 'when force_type: actionable is provided' do
      let(:show_parameters) do
        { id: '123', format: 'json', force_type: 'actionable' }
      end

      it 'should call clear_error! on statement' do
        expect(statement).to receive(:clear_error!)
        get :show, params: show_parameters
      end
    end
  end
end

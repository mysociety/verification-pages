# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReconciliationsController, type: :controller do
  let(:statement) { double(:statement).as_null_object }
  let(:relation) { double(:reconciliation_relation).as_null_object }
  let(:classifier) { double(:classifier) }

  let(:valid_attributes) do
    { id: '123', user: 'ExampleUser', item: 'Q1', resource_type: 'person',
      format: 'json', }
  end

  describe 'POST #create' do
    before do
      allow(Statement).to receive(:find_by!).and_return(statement)
      allow(statement).to receive(:reconciliations).and_return(relation)
      allow(StatementClassifier).to receive(:new).and_return(classifier)
    end

    it 'finds statement and creates reconciliation' do
      expect(Statement).to receive(:find_by!).with(transaction_id: '123')
      post :create, params: valid_attributes
      expect(relation).to have_received(:create!)
        .with('user' => 'ExampleUser', 'item' => 'Q1',
              'resource_type' => 'person')
    end

    it 'assigns classifier' do
      post :create, params: valid_attributes
      expect(assigns(:classifier)).to eq classifier
    end

    it 'renders statements show JSON' do
      post :create, params: valid_attributes
      expect(response).to render_template('statements/index')
    end
  end
end

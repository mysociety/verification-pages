# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VerificationsController, type: :controller do
  let(:statement) { double(:statement).as_null_object }
  let(:relation) { double(:verification_relation).as_null_object }
  let(:classifier) { double(:classifier) }

  let(:valid_attributes) do
    { id: '123', user: 'ExampleUser', status: 'true', format: 'json' }
  end

  describe 'POST #create' do
    before do
      allow(Statement).to receive(:find_by!).and_return(statement)
      allow(statement).to receive(:verifications).and_return(relation)
      allow(StatementClassifier).to receive(:new).and_return(classifier)
    end

    it 'finds statement and creates verification' do
      expect(Statement).to receive(:find_by!).with(transaction_id: '123')
      post :create, params: valid_attributes
      expect(relation).to have_received(:create!)
        .with('user' => 'ExampleUser', 'status' => 'true')
    end

    it 'assigns classifier' do
      post :create, params: valid_attributes
      expect(assigns(:classifier)).to eq classifier
    end

    it 'renders statements show JSON' do
      post :create, params: valid_attributes
      expect(response).to render_template('statements/index')
    end

    it 'can correct the name of the person if supplied' do
      valid_attributes_new_name = {
        id: '456', user: 'ExampleUser', status: 'true', new_name: 'Joseph Bloggs', format: 'json'
      }
      expect(Statement).to receive(:find_by!).with(transaction_id: '456')
      expect(statement).to receive(:update_attributes).with(person_name: 'Joseph Bloggs')
      post :create, params: valid_attributes_new_name
      expect(relation).to have_received(:create!)
        .with('user' => 'ExampleUser', 'status' => 'true', 'new_name' => 'Joseph Bloggs')
    end
  end
end

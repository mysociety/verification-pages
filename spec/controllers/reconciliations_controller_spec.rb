# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReconciliationsController, type: :controller do
  let(:statement) do
    Statement.create(
      transaction_id: '123',
      parliamentary_term_item: 'Q1'
    )
  end

  let(:valid_attributes) do
    { id: '123', user: 'ExampleUser', item: 'Q1', format: 'json' }
  end

  describe 'POST #create' do
    let(:page) { double(:page, title: 'Page title') }
    let(:reconcilation_scope) { double(:relation) }
    let(:classifier) { double }

    before do
      allow(Statement).to receive(:find_by!).and_return(statement)
      allow(statement).to receive(:page).and_return(page)
      allow(StatementClassifier).to receive(:new).and_return(classifier)
    end

    it 'finds statement and creates reconciliation' do
      expect(Statement).to receive(:find_by!).with(transaction_id: '123')
      expect do
        post :create, params: valid_attributes
      end.to change(Reconciliation, :count).by(1)
    end

    it 'assigns classifier' do
      post :create, params: valid_attributes
      expect(assigns(:classifier)).to eq classifier
    end

    it 'renders statements show JSON' do
      post :create, params: valid_attributes
      expect(response).to render_template('statements/show')
    end
  end
end

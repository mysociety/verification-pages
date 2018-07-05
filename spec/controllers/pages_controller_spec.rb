# frozen_string_literal: true

require 'rails_helper'
require 'csv'

RSpec.describe PagesController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # Page. As you add validations to Page, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    { title: 'Page title', position_held_item: 'Q1',
      parliamentary_term_item: 'Q2', reference_url: 'http://example.com',
      country_id: country.id, csv_source_url: 'http://example.com/export.csv' }
  end

  let(:invalid_attributes) do
    { title: nil }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # PagesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  let(:country) { create(:country) }

  describe 'GET #index' do
    it 'returns a success response' do
      get :index, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      page = Page.create! valid_attributes
      get :show, params: { id: page.to_param }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new, params: {}, session: valid_session
      expect(response).to be_successful
    end

    context 'with querystring parameters' do
      it 'uses them to populate new Page instance' do
        get :new, params: {
          title: 'Test title',
          position_held_item: 'Q123321',
          csv_source_url: 'https://example.com/export.csv'
        }, session: valid_session
        page = @controller.view_assigns['page']
        expect(page.title).to eq('Test title')
        expect(page.position_held_item).to eq('Q123321')
        expect(page.csv_source_url).to eq('https://example.com/export.csv')
      end
    end
  end

  describe 'GET #edit' do
    it 'returns a success response' do
      page = Page.create! valid_attributes
      get :edit, params: { id: page.to_param }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Page' do
        expect do
          post :create, params: { page: valid_attributes },
                        session: valid_session
        end.to change(Page, :count).by(1)
      end

      it 'redirects to the created page' do
        post :create, params: { page: valid_attributes }, session: valid_session
        expect(response).to redirect_to(Page.last)
      end
    end

    context 'with invalid params' do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { page: invalid_attributes },
                      session: valid_session
        expect(response).to be_successful
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) do
        { title: 'New title' }
      end

      it 'updates the requested page' do
        page = Page.create! valid_attributes
        put :update, params: { id: page.to_param, page: new_attributes },
                     session: valid_session
        page.reload
        expect(page.title).to eq 'New title'
      end

      it 'redirects to the page' do
        page = Page.create! valid_attributes
        put :update, params: { id: page.to_param, page: valid_attributes },
                     session: valid_session
        expect(response).to redirect_to(page)
      end
    end

    context 'with invalid params' do
      it "returns a success response (i.e. to display the 'edit' template)" do
        page = Page.create! valid_attributes
        put :update, params: { id: page.to_param, page: invalid_attributes },
                     session: valid_session
        expect(response).to be_successful
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested page' do
      page = Page.create! valid_attributes
      expect do
        delete :destroy, params: { id: page.to_param }, session: valid_session
      end.to change(Page, :count).by(-1)
    end

    it 'redirects to the pages list' do
      page = Page.create! valid_attributes
      delete :destroy, params: { id: page.to_param }, session: valid_session
      expect(response).to redirect_to(pages_url)
    end
  end

  describe 'POST #load' do
    before do
      suggestions_store_response = [
        %w[transaction_id],
        %w[489434391472318],
        %w[1656343594481923]
      ].map(&:to_csv).join

      stub_request(:get, 'http://example.com/export.csv')
        .to_return(status: 200, body: suggestions_store_response, headers: {})
    end

    it 'loads statements for the given page' do
      page = Page.create! valid_attributes
      expect do
        post :load, params: { id: page.to_param }, session: valid_session
      end.to change(page.statements, :count).by(2)
    end
  end

  describe 'POST #create_wikidata' do
    let(:page) { Page.create! valid_attributes }

    before do
      allow(UpdateVerificationPage).to receive(:run)
    end

    it 'runs the UpdateVerificationPage service' do
      expect(UpdateVerificationPage).to receive(:run).with(page.title)
      post :create_wikidata, params: { id: page.to_param }, session: valid_session
    end

    it 'redirects to pages#show' do
      response = post :create_wikidata, params: { id: page.to_param }, session: valid_session
      expect(response).to redirect_to(page_path(page))
    end

    it 'sets a flash notice' do
      post :create_wikidata, params: { id: page.to_param }, session: valid_session
      expect(flash[:notice]).to be_present
    end
  end
end

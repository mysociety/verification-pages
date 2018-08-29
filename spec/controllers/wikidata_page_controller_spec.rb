# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WikidataPageController, type: :controller do
  describe 'GET /setup' do
    let!(:canada) { create(:country, code: 'ca') }
    let(:wikidata_url) { 'https://www.wikidata.org/wiki/Test_Page' }
    let(:wikipage) do
      double(
        WikiPageTemplateTag,
        page_attributes: {
          position_held_item:      'Q123',
          country:                 canada,
          parliamentary_term_item: 'Q456',
          csv_source_url:          'https://example.com/members.csv',
        },
        update_page:     true,
        wikidata_url:    wikidata_url
      )
    end

    let(:valid_params) { { page_title: 'Test_Page' } }

    before do
      allow(WikiPageTemplateTag).to receive(:new).and_return(wikipage)
      allow(LoadStatements).to receive(:run)
      allow(GenerateVerificationPage).to receive(:run).and_return(double(wikitext: 'test text'))
    end

    it "creates a new page if there isn't an existing one" do
      expect { get :setup, params: valid_params }.to change(Page, :count).by(1)
    end

    it 'uses existing page if there is one' do
      create(:page, title: 'Test_Page')
      expect { get :setup, params: valid_params }.to_not change(Page, :count)
    end

    it 'redirect to the wikidata URL' do
      response = get :setup, params: valid_params
      expect(response).to redirect_to(wikidata_url)
    end

    it "renders an error page if there's a problem updating the page" do
      allow(wikipage).to receive(:page_attributes).and_return({})
      response = get :setup, params: valid_params
      expect(response).to render_template(:wikidata_page_setup_error)
    end
  end
end

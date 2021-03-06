# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WikidataPageController, type: :controller do
  describe 'GET /setup' do
    let(:wikidata_url) { 'https://www.wikidata.org/wiki/Test_Page' }
    let(:wikipage) do
      double(
        WikiPageTemplateTag,
        page_attributes: {
          position_held_item:      'Q123',
          country_item:            'Q16',
          country_code:            'ca',
          parliamentary_term_item: 'Q456',
          csv_source_url:          'https://example.com/members.csv',
          csv_source_language:     'en',
          new_item_description_en: 'Canadian politician',
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

    it 'updates page with new attributes' do
      page = double(:page, title: 'Test_Page')
      allow(Page).to receive(:find_or_initialize_by).with(title: 'Test_Page').and_return(page)
      expect(page).to receive(:update).with(wikipage.page_attributes)
      get :setup, params: valid_params
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

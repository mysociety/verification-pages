# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WikiPageTemplateTag, type: :service do
  let(:page_title) { 'Test_Page' }

  let(:wiki_template) do
    <<~TEMPLATE
      {{#{subject.send(:wiki_template_name)}
      |country_code=ca
      |position_held_item=Q123
      |parliamentary_term_item=Q456
      |csv_source_url=https://example.com/members.csv
      }}
    TEMPLATE
  end

  let(:api_url) do
    "https://#{ENV['WIKIDATA_SITE']}/w/api.php"
  end

  let(:raw_wikitext_url) do
    "https://#{ENV['WIKIDATA_SITE']}/w/index.php?action=raw&title=#{page_title}"
  end

  let(:csrftoken_url) do
    "https://#{ENV['WIKIDATA_SITE']}/w/api.php?action=query&format=json&meta=tokens&type=csrf"
  end

  let!(:canada) do
    create(:country, code: 'ca')
  end

  subject { WikiPageTemplateTag.new(page_title) }

  before do
    stub_request(:post, api_url).to_return(body: '{"result":"Success"}')
    stub_request(:get, raw_wikitext_url).to_return(body: wiki_template)
    stub_request(:get, csrftoken_url).to_return(body: '{"tokens":{"csrftoken":"foo"}}')
    allow(subject).to receive(:wiki_username).and_return('test')
    allow(subject).to receive(:wiki_password).and_return('test')
  end

  describe '#page_attributes' do
    it 'parses the correct attributes from the template' do
      expect(subject.page_attributes).to eq(
        country:                 canada,
        position_held_item:      'Q123',
        parliamentary_term_item: 'Q456',
        csv_source_url:          'https://example.com/members.csv'
      )
    end
  end

  describe '#update_page' do
    let(:template_text) do
      "#{wiki_template}test content\n<!-- OUTPUT END Created or updated verification page -->\n"
    end

    let(:expected_post_body) do
      'action=edit&format=json&' \
        "text=#{URI.encode_www_form_component(template_text)}&title=#{page_title}&token=foo"
    end

    it 'calls the Wikidata API and updates the page contents' do
      subject.update_page('test content')
      expect(WebMock).to have_requested(:post, api_url).with(body: expected_post_body)
    end
  end

  describe '#wikidata_url' do
    it 'is correct' do
      expected = "https://#{ENV['WIKIDATA_SITE']}/wiki/#{page_title}"
      expect(subject.wikidata_url).to eq(expected)
    end
  end
end

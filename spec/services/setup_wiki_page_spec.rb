# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SetupWikiPage, type: :service do
  let(:page_title) { 'Test_Page' }
  subject { SetupWikiPage.new(page_title) }

  before do
    # Login
    stub_request(:post, "https://#{ENV['WIKIDATA_SITE']}/w/api.php")
      .to_return(body: '{"result":"Success"}')
    # Get Test_Page/settings.json
    stub_request(:get, "https://#{ENV['WIKIDATA_SITE']}/w/index.php?action=raw&title=#{page_title}/settings.json")
      .to_return(body: JSON.generate(position_held_item: 'Q123', country_code: 'ca', csv_source_url: 'https://example.com/members.csv'))
    create(:country, code: 'ca')
    allow(LoadStatements).to receive(:run)
    allow(UpdateVerificationPage).to receive(:run)
  end

  it 'creates a new page' do
    expect { subject.run }.to change(Page, :count).by(1)
  end

  it 'runs the LoadStatements service' do
    expect(LoadStatements).to receive(:run).with(page_title)
    subject.run
  end

  it 'runs the UpdateVerificationPage service' do
    expect(UpdateVerificationPage).to receive(:run).with(page_title)
    subject.run
  end

  describe '#redirect_url' do
    it 'is correct' do
      expected = "https://#{ENV['WIKIDATA_SITE']}/wiki/#{page_title}"
      expect(subject.redirect_url).to eq(expected)
    end
  end
end

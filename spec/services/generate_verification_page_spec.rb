# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenerateVerificationPage, type: :service do
  let(:service) { GenerateVerificationPage.new('page_title') }
  let(:page) { Page.new(title: 'page_title', position_held_item: 'Q1') }

  before do
    allow(Page).to receive(:find_by!).with(title: 'page_title').and_return(page)
  end

  describe 'initialisation' do
    it 'finds page and assigns instance variable' do
      expect(Page).to receive(:find_by!).with(title: 'page_title')
      expect(service.page).to eq page
    end
  end

  describe '#run' do
    it 'calls render with page and classified statements' do
      position_held_data = double(:position_held_data)
      allow(RetrievePositionData).to receive(:run)
        .with(page.position_held_item)
        .and_return(position_held_data)

      classify_page = double(:classify_page)
      expect(PageClassifier).to receive(:new)
        .with('page_title')
        .and_return(classify_page)

      template = Rails.root.join('app', 'views', 'wiki', 'verification.mediawiki.erb')

      expect(service).to receive(:render)
        .with(template, page: page, statements: classify_page)

      service.run
    end
  end
end

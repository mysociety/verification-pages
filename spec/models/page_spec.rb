# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Page, type: :model do
  let(:page) { Page.new }

  describe 'associations' do
    it 'has many statements' do
      expect(page.statements.build).to be_a(Statement)
    end
  end

  describe 'validations' do
    before { page.valid? }

    it 'requires title' do
      expect(page.errors).to include(:title)
    end

    it 'requires position_held_item' do
      expect(page.errors).to include(:position_held_item)
    end

    it 'requires csv_source_url' do
      expect(page.errors).to include(:csv_source_url)
    end
  end

  describe '#from_suggestions_store?' do
    it 'knows that it came from suggestions-store' do
      page = create(:page, csv_source_url: "#{ENV.fetch('SUGGESTIONS_STORE_URL')}/export/blah.csv")
      expect(page.from_suggestions_store?).to eq(true)
    end

    it 'know that it didn\'t come from suggestions-store' do
      page = create(:page)
      expect(page.from_suggestions_store?).to eq(false)
    end
  end
end

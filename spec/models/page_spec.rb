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

  describe 'before validation' do
    let(:page) { build(:page, position_held_item: 'Q2', parliamentary_term_item: 'Q3') }

    before do
      allow(RetrieveLabels).to receive(:run).with('Q2', 'Q3').and_return(
        'Q2' => 'Position', 'Q3' => 'Term'
      )
    end

    context 'position held item changed' do
      before { allow(page).to receive(:position_held_item_changed?) { true } }

      it 'should set position held name' do
        expect { page.valid? }.to change(page, :position_held_name).to('Position')
      end
    end

    context 'position held item is unchanged' do
      before { allow(page).to receive(:position_held_item_changed?) { false } }

      it 'should not set position held name' do
        expect { page.valid? }.to_not change(page, :position_held_name)
      end
    end

    context 'parliamentary term item changed' do
      before { allow(page).to receive(:parliamentary_term_item_changed?) { true } }

      it 'should set parliamentary term name' do
        expect { page.valid? }.to change(page, :parliamentary_term_name).to('Term')
      end
    end

    context 'position held item is unchanged' do
      before { allow(page).to receive(:parliamentary_term_item_changed?) { false } }

      it 'should not set position held name' do
        expect { page.valid? }.to_not change(page, :parliamentary_term_name)
      end
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

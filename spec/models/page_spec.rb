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

    context 'hash epoch eq 2' do
      let(:page) { Page.new(hash_epoch: 2) }

      it 'requires country_code' do
        expect(page.errors).to include(:country_code)
      end

      it 'does not requires country_item' do
        expect(page.errors).not_to include(:country_item)
      end
    end

    context 'hash epoch eq 3' do
      let(:page) { Page.new(hash_epoch: 3) }

      it 'does not requires country_code' do
        expect(page.errors).not_to include(:country_code)
      end

      it 'requires country_item' do
        expect(page.errors).to include(:country_item)
      end
    end
  end

  describe 'before validation' do
    let(:page) do
      build(:page, position_held_item: 'Q2', parliamentary_term_item: 'Q3', country_item: 'Q4')
    end

    before do
      allow(RetrieveItems).to receive(:run).with('Q2', 'Q3', 'Q4').and_return(
        'Q2' => OpenStruct.new(label: 'Position'),
        'Q3' => OpenStruct.new(label: 'Term'),
        'Q4' => OpenStruct.new(label: 'Country')
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

    context 'country item changed' do
      before { allow(page).to receive(:country_item_changed?) { true } }

      it 'should set country name' do
        expect { page.valid? }.to change(page, :country_name).to('Country')
      end
    end

    context 'position held item is unchanged' do
      before { allow(page).to receive(:country_item_changed?) { false } }

      it 'should not set position held name' do
        expect { page.valid? }.to_not change(page, :country_name)
      end
    end
  end

  describe '#from_suggestions_store?' do
    before do
      stub_const('SuggestionsStore::Request::URL', 'http://suggestions-store/')
    end

    it 'knows that it came from suggestions-store' do
      page = create(:page, csv_source_url: 'http://suggestions-store/export/blah.csv')
      expect(page.from_suggestions_store?).to eq(true)
    end

    it 'know that it didn\'t come from suggestions-store' do
      page = create(:page, csv_source_url: 'http://example.com')
      expect(page.from_suggestions_store?).to eq(false)
    end
  end
end

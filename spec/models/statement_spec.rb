# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Statement, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  let(:statement) { build(:statement) }

  describe 'associations' do
    it 'belongs to a page' do
      expect(statement.build_page).to be_a(Page)
    end

    it 'has many verifications' do
      expect(statement.verifications.build).to be_a(Verification)
    end

    it 'has many reconciliations' do
      expect(statement.reconciliations.build).to be_a(Reconciliation)
    end
  end

  describe 'validations' do
    let(:statement) { Statement.new }

    it 'requires transaction_id' do
      statement.valid?
      expect(statement.errors).to include(:transaction_id)
    end

    it 'require unique transaction_id' do
      create(:statement, transaction_id: '123')
      statement.transaction_id = '123'
      statement.valid?
      expect(statement.errors).to include(:transaction_id)
    end
  end

  describe 'delegations' do
    it 'delegates #parliamentary_term_item to page association' do
      allow(statement).to receive(:page)
        .and_return(double(:page, parliamentary_term_item: 'Q1'))
      expect(statement.parliamentary_term_item).to eq('Q1')
    end
  end

  it 'can create instance without person_item and fb_identifier' do
    expect(create(:statement, transaction_id: '123', person_item: nil, fb_identifier: nil)).to be_a Statement
    expect(create(:statement, transaction_id: '456', person_item: '', fb_identifier: '')).to be_a Statement
  end

  describe '#from_suggestions_store?' do
    before do
      stub_const('SuggestionsStore::Request::URL', 'http://suggestions-store/')
    end

    it 'knows that it came from suggestions-store' do
      page = create(:page, csv_source_url: 'http://suggestions-store/export/blah.csv')
      statement = create(:statement, page: page)
      expect(statement.from_suggestions_store?).to eq(true)
    end

    it 'know that it didn\'t come from suggestions-store' do
      page = create(:page, csv_source_url: 'http://example.com')
      statement = create(:statement, page: page)
      expect(statement.from_suggestions_store?).to eq(false)
    end
  end

  describe '#record_actioned!' do
    before { freeze_time }

    it 'assigns actioned_at' do
      expect { statement.record_actioned! }.to(
        change(statement, :actioned_at).from(nil).to(Time.zone.now)
      )
    end

    it 'assigns classifier_version' do
      expect { statement.record_actioned!('v2') }.to(
        change(statement, :classifier_version).from(1).to(2)
      )
    end
  end

  describe '#report_error!' do
    before { freeze_time }

    it 'assigns reported_at' do
      expect { statement.report_error!('Error') }.to(
        change(statement, :reported_at).from(nil).to(Time.zone.now)
      )
    end

    it 'assigns error_reported' do
      expect { statement.report_error!('Error') }.to(
        change(statement, :error_reported).from(nil).to('Error')
      )
    end
  end

  describe '#clear_error!' do
    let(:statement) do
      build(:statement, reported_at: Time.zone.now, error_reported: 'Error')
    end

    it 'unassigns reported_at' do
      expect { statement.clear_error! }.to(
        change(statement, :reported_at).to(nil)
      )
    end

    it 'unassigns error_reported' do
      expect { statement.clear_error! }.to(
        change(statement, :error_reported).to(nil)
      )
    end
  end

  describe '#self_and_duplicate_statements' do
    let(:page) { build(:page) }
    let(:page_2) { build(:page) }

    let(:attributes) { attributes_for(:statement_with_names) }

    let!(:statement) do
      create(:statement, attributes.merge(transaction_id: '123', page: page))
    end

    let!(:duplicate) do
      create(:statement, attributes.merge(transaction_id: '456', page: page))
    end

    let!(:other) do
      create(:statement, attributes.merge(transaction_id: '789', page: page_2))
    end

    subject { statement.self_and_duplicate_statements }

    it 'returns self' do
      is_expected.to include(statement)
    end

    it 'returns statements' do
      is_expected.to include(duplicate)
    end

    it 'does not returns statements from other pages' do
      is_expected.to_not include(other)
    end
  end

  describe '#duplicate_statements' do
    let(:page) { build(:page) }
    let(:page_2) { build(:page) }

    let(:attributes) { attributes_for(:statement_with_names) }

    let!(:statement) do
      create(:statement, attributes.merge(transaction_id: '123', page: page))
    end

    let!(:duplicate) do
      create(:statement, attributes.merge(transaction_id: '456', page: page))
    end

    let!(:other) do
      create(:statement, attributes.merge(transaction_id: '789', page: page_2))
    end

    subject { statement.duplicate_statements }

    it 'does not returns self' do
      is_expected.to_not include(statement)
    end

    it 'returns statements' do
      is_expected.to include(duplicate)
    end

    it 'does not returns statements from other pages' do
      is_expected.to_not include(other)
    end
  end

  describe '#verify_duplicates! after_create callback' do
    let(:page) { build(:page) }

    let(:attributes) { attributes_for(:statement_with_names) }

    let!(:statement) do
      create(:statement, attributes.merge(transaction_id: '123', page: page))
    end

    before do
      statement.verifications.create!(
        reference_url: 'http://example.com/members/',
        user:          'TestUser'
      )
    end

    it 'creates verifications for the duplicate' do
      new_duplicate = create(:statement, attributes.merge(transaction_id: '456', page: page))
      expect(new_duplicate.verifications.size).to be(1)
    end
  end
end

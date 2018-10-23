# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NewStatementDecorator, type: :decorator do
  let(:object) { build(:statement, person_item: 'Q1') }
  let(:comparisons) do
    OpenStruct.new(
      exact_matches:   ['UUID-1'],
      conflicts:       ['UUID-2'],
      partial_matches: ['UUID-3']
    )
  end
  let(:statement) { NewStatementDecorator.new(object, comparisons) }

  describe 'initialisation' do
    it 'does not replace existing values' do
      expect(statement.person_item).to eq 'Q1'
    end

    it 'updates missing values' do
      expect(statement.statement_uuid).to eq 'UUID-1'
    end
  end

  describe '#reconciliations_required' do
    let(:page) { build(:page) }
    let(:object) { build(:statement, person_item: 'Q1', page: page) }

    subject { statement.reconciliations_required }

    context 'when person has been reconciled' do
      before { statement.person_item = 'Q1' }
      it { is_expected.to match_array([]) }
    end

    context 'when person hasn\'t been reconciled' do
      before { statement.person_item = nil }
      it { is_expected.to match_array(%w[person]) }
    end

    context 'when the district has been reconciled' do
      before { statement.electoral_district_item = 'Q123' }
      it { is_expected.to match_array([]) }
    end

    context 'when the district hasn\'t been reconciled but there was no name to reconcile' do
      before do
        statement.electoral_district_item = nil
        statement.electoral_district_name = nil
      end
      it { is_expected.to match_array([]) }
    end

    context 'when the district hasn\'t been reconciled but there was a name to reconcile' do
      before do
        statement.electoral_district_item = nil
        statement.electoral_district_name = 'Cambridge'
      end
      it { is_expected.to match_array(%w[district]) }
    end

    context 'when the party hasn\'t been reconciled but there was no name to reconcile' do
      before do
        statement.parliamentary_group_item = nil
        statement.parliamentary_group_name = nil
      end
      it { is_expected.to match_array([]) }
    end

    context 'when the party hasn\'t been reconciled but there was a name to reconcile' do
      before do
        statement.parliamentary_group_item = nil
        statement.parliamentary_group_name = 'Greens'
      end
      it { is_expected.to match_array(%w[party]) }
    end

    context 'when neither person, party or district have been reconciled' do
      before do
        statement.person_item = nil
        statement.parliamentary_group_item = nil
        statement.parliamentary_group_name = 'Greens'
        statement.electoral_district_item = nil
        statement.electoral_district_name = 'Cambridge'
      end
      it { is_expected.to match_array(%w[person party district]) }
    end
  end

  describe '#verified_on' do
    subject { statement.verified_on }

    context 'with verification' do
      let(:time) { Time.utc(2018, 1, 1, 13, 45) }
      before do
        allow(statement).to receive(:latest_verification).and_return(
          Verification.new(created_at: time)
        )
      end

      it { is_expected.to eq Date.new(2018, 1, 1) }
    end

    context 'without verification' do
      before do
        allow(statement).to receive(:latest_verification).and_return(nil)
      end
      it { is_expected.to be_nil }
    end
  end
end

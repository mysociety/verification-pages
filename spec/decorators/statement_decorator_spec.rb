# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatementDecorator, type: :decorator do
  let(:object) { build(:statement, person_item: 'Q1') }
  let(:matching_position_held_data) do
    [OpenStruct.new(revision: '123', position: 'UUID')]
  end
  let(:statement) { StatementDecorator.new(object, matching_position_held_data) }

  describe 'initialisation' do
    it 'does not replace existing values' do
      expect(statement.person_item).to eq 'Q1'
    end

    it 'updates missing values' do
      expect(statement.person_revision).to eq '123'
      expect(statement.statement_uuid).to eq 'UUID'
    end
  end

  describe '#problems' do
    context 'when there are multiple matching statements' do
      let(:matching_position_held_data) do
        [
          OpenStruct.new(person_item: 'Q1', revision: '123', position: 'UUID1'),
          OpenStruct.new(person_item: 'Q1', revision: '234', position: 'UUID2'),
        ]
      end
      let(:expected_error) do
        'There were 2 \'position held\' (P39) statements on Wikidata that match the verified suggestion - one or more of them might be missing an end date or parliamentary term qualifier'
      end
      it 'should find a problem with there being multiple matching statements' do
        expect(statement.statement_problems).to eq([expected_error])
      end
    end

    context 'when there are no matching statements' do
      let(:matching_position_held_data) { [] }
      let(:expected_error) do
        'There were no \'position held\' (P39) statements on Wikidata that match the actioned suggestion'
      end
      before { allow(statement).to receive(:actioned_at?).and_return(true) }
      it 'should find a problem with there being no matching statements' do
        expect(statement.statement_problems).to eq([expected_error])
      end
    end

    context 'when electoral districts contradict' do
      let(:object) do
        create(
          :statement,
          person_item:             'Q1',
          electoral_district_item: 'Q789'
        )
      end
      let(:matching_position_held_data) do
        [OpenStruct.new(revision: '123', position: 'UUID', district: 'Q345')]
      end
      let(:expected_error) do
        'The electoral district is different in the statement (Q789) and on Wikidata (Q345)'
      end
      it 'should find a problem with the electoral districts' do
        expect(statement.electoral_district_problems).to eq([expected_error])
      end
      it 'should find a problem overall' do
        expect(statement.problems).to eq([expected_error])
      end
    end

    context 'when parliamentary groups (parties) contradict' do
      let(:object) do
        build(
          :statement,
          person_item:              'Q1',
          parliamentary_group_item: 'Q123'
        )
      end
      let(:matching_position_held_data) do
        [OpenStruct.new(revision: '123', position: 'UUID', group: 'Q234')]
      end
      let(:expected_error) do
        'The parliamentary group (party) is different in the statement (Q123) and on Wikidata (Q234)'
      end
      it 'should find a problem with the parliamentary groups' do
        expect(statement.parliamentary_group_problems).to eq([expected_error])
      end
      it 'should find a problem overall' do
        expect(statement.problems).to eq([expected_error])
      end
    end

    context 'when the position start date on Wikidata is more than 31 days before the start of the term' do
      let(:matching_position_held_data) do
        [
          OpenStruct.new(
            revision:       '123',
            position:       'UUID',
            position_start: '2013-12-15',
            term_start:     '2014-01-31'
          ),
        ]
      end
      let(:expected_error) do
        'On Wikidata, the position held start date (2013-12-15) was before the term start date (2014-01-31)'
      end
      it 'should find a problem with the start date' do
        expect(statement.start_date_before_term_problems).to eq([expected_error])
      end
      it 'should find a problem overall' do
        expect(statement.problems).to eq([expected_error])
      end
    end

    context 'when the position start date on Wikidata is the day before the start of the term' do
      let(:matching_position_held_data) do
        [
          OpenStruct.new(
            revision:       '123',
            position:       'UUID',
            position_start: '2014-01-06',
            term_start:     '2014-01-07'
          ),
        ]
      end
      it 'should find no problem with the start date' do
        expect(statement.start_date_before_term_problems).to be_empty
      end
      it 'should find no problems overall' do
        expect(statement.problems).to be_empty
      end
    end

    context 'when the position start date on Wikidata is the after the start of the term' do
      let(:matching_position_held_data) do
        [
          OpenStruct.new(
            revision:       '123',
            position:       'UUID',
            position_start: '2014-01-06',
            term_start:     '2014-01-04'
          ),
        ]
      end
      it 'should find no problem with the start date' do
        expect(statement.start_date_before_term_problems).to be_empty
      end
      it 'should find no problems overall' do
        expect(statement.problems).to be_empty
      end
    end

    context 'when all problems apart from multiple P39s happen for the same data' do
      let(:object) do
        create(
          :statement,
          person_item:              'Q1',
          parliamentary_group_item: 'Q123',
          electoral_district_item:  'Q789'
        )
      end
      let(:matching_position_held_data) do
        [
          OpenStruct.new(
            revision:       '123',
            position:       'UUID',
            position_start: '2013-12-15',
            term_start:     '2014-01-31',
            district:       'Q345',
            group:          'Q234'
          ),
        ]
      end
      it 'should report all those problems' do
        expected_errors = [
          'The electoral district is different in the statement (Q789) and on Wikidata (Q345)',
          'The parliamentary group (party) is different in the statement (Q123) and on Wikidata (Q234)',
          'On Wikidata, the position held start date (2013-12-15) was before the term start date (2014-01-31)',
        ]
        expect(statement.problems).to eq(expected_errors)
      end
    end

    context 'when all known problems happen for the same data' do
      let(:object) do
        create(
          :statement,
          person_item:              'Q1',
          parliamentary_group_item: 'Q123',
          electoral_district_item:  'Q789'
        )
      end
      let(:matching_position_held_data) do
        [
          OpenStruct.new(
            revision:       '123',
            position:       'UUID',
            position_start: '2013-12-15',
            term_start:     '2014-01-31',
            district:       'Q345',
            group:          'Q234'
          ),
          OpenStruct.new,
        ]
      end
      it 'should only report the P39 all those problems' do
        expected_errors = [
          'There were 2 \'position held\' (P39) statements on Wikidata that match the verified suggestion - one or more of them might be missing an end date or parliamentary term qualifier',
        ]
        expect(statement.problems).to eq(expected_errors)
      end
    end

    context 'when a source contains no district information' do
      let(:object) do
        build(
          :statement,
          person_item:              'Q1',
          parliamentary_group_item: 'Q123',
          electoral_district_name:  'Somewhereville'
        )
      end
      let(:matching_position_held_data) do
        [
          OpenStruct.new(
            revision:       '123',
            position:       'UUID',
            position_start: '2014-01-31',
            term_start:     '2014-01-31',
            district:       'Q345',
            group:          'Q123'
          ),
        ]
      end
      it 'should not report any problems with district' do
        expect(statement.problems).to eq([])
      end
    end

    context 'when a source contains no parliamentary group information' do
      let(:object) do
        build(
          :statement,
          person_item:             'Q1',
          electoral_district_item: 'Q345',
          electoral_district_name: 'Somewhereville'
        )
      end
      let(:matching_position_held_data) do
        [
          OpenStruct.new(
            revision:       '123',
            position:       'UUID',
            position_start: '2014-01-31',
            term_start:     '2014-01-31',
            district:       'Q345',
            group:          'Q123'
          ),
        ]
      end
      it 'should not report any problems with district' do
        expect(statement.problems).to eq([])
      end
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

  describe '#person_matches?' do
    let(:matching_position_held_data) { [] }
    context 'with no matching position held data' do
      it 'returns false' do
        expect(statement.send(:person_matches?)).to be false
      end
    end
  end
end

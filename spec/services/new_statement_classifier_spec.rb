# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NewStatementClassifier, type: :service do
  include ActiveSupport::Testing::TimeHelpers

  let(:page) do
    build(:page, csv_source_url: 'http://suggestions-store/export/ca.csv')
  end

  let(:data) { { person_item: 'Q1' } }
  let(:statement) { build(:statement, data.merge(page: page)) }
  let(:statements) { [statement].compact }
  let(:statement_relation) { double(:relation, to_a: statements) }

  let(:wikidata_data) do
    { person: 'Q1', merged_then_deleted: '', position: 'UUID' }
  end
  let(:position_held) { OpenStruct.new(wikidata_data) }
  let(:position_held_data) { [position_held] }

  let(:exact_matches) { [] }
  let(:conflicts) { [] }
  let(:partial_matches) { [] }
  let(:problems) { {} }
  let(:comparison) do
    OpenStruct.new(
      exact_matches:   exact_matches,
      conflicts:       conflicts,
      partial_matches: partial_matches,
      problems:        problems
    )
  end

  let(:classifier) { NewStatementClassifier.new('page_title') }

  before do
    stub_const('SuggestionsStore::Request::URL', 'http://suggestions-store/')
    allow(statement_relation).to receive_message_chain(
      :original, :includes, :references, :order
    ).and_return(statement_relation)
    allow(Page).to receive(:find_by!)
      .with(title: 'page_title')
      .and_return(page)
    allow(page).to receive(:statements)
      .and_return(statement_relation)

    allow(RetrieveTermData).to receive(:run)
      .with(page.parliamentary_term_item)
      .and_return(OpenStruct.new(start: '2018-01-01', end: '2019-01-01'))
    allow(NewRetrievePositionData).to receive(:run)
      .with(page.position_held_item, nil)
      .and_return(position_held_data)
    allow(MembershipComparison).to receive(:new)
      .and_return(comparison)
  end

  describe 'initialisation' do
    it 'assigns instance variables' do
      expect(classifier.page).to eq page
      expect(classifier.statements).to eq statement_relation
    end
  end

  describe '#to_a' do
    subject { classifier.to_a }

    it 'should return decorated statements' do
      is_expected.to include(a_kind_of(NewStatementDecorator))
    end

    it 'should not return items without types' do
      allow(classifier).to receive(:statement_type).and_return(nil)
      is_expected.to match_array([])
    end
  end

  describe 'statement classification' do
    let(:data) do
      { person_item:              '',
        parliamentary_group_item: 'Q3',
        electoral_district_item:  'Q4', }
    end

    let(:wikidata_data) do
      { person:              'Q1',
        merged_then_deleted: '',
        term:                'Q2',
        term_start:          '2018-01-01',
        position_start:      '2018-01-01',
        group:               'Q3',
        district:            'Q4', }
    end

    context 'when verifiable' do
      include_examples 'classified as', 'verifiable'
    end

    context 'when the statements are reconciled but not verified' do
      let(:partial_matches) { ['UUID'] }

      before do
        allow(statement).to receive(:person_item).and_return('Q1')
      end

      include_examples 'classified as', 'verifiable'
    end

    context 'when the statement is from suggestions-store and is already correct (apart from the reference) in Wikidata' do
      let(:partial_matches) { ['UUID'] }

      before do
        allow(statement).to receive(:person_item).and_return('Q1')
      end

      include_examples 'classified as', 'verifiable'
    end

    context 'when unverifiable' do
      before { statement.verifications.build(status: false) }
      include_examples 'classified as', 'unverifiable'
    end

    context 'when unverifiable (although otherwise would be marked "manually actionable")' do
      before do
        statement.verifications.build(status: false)
        allow(statement).to receive(:person_item).and_return('Q1')
        position_held.district = 'other-district'
      end

      include_examples 'classified as', 'unverifiable'
    end

    context 'when verified' do
      let(:partial_matches) { ['UUID'] }

      before { statement.verifications.build(status: true) }
      include_examples 'classified as', 'reconcilable'
    end

    context 'when statement is actionable' do
      let(:partial_matches) { ['UUID'] }

      before do
        position_held.group = nil
        statement.verifications.build(status: true)
        allow(statement).to receive(:person_item).and_return('Q1')
      end

      include_examples 'classified as', 'actionable'
    end

    context 'when conflicting Wikidata statement' do
      let(:conflicts) { ['UUID'] }
      let(:problems) { { 'UUID' => ['A problem'] } }

      before do
        statement.verifications.build(status: true)
        allow(statement).to receive(:person_item).and_return('Q1')
      end

      include_examples 'classified as', 'manually_actionable'
    end

    context 'when statement has been reported' do
      before do
        statement.verifications.build(status: true)
        allow(statement).to receive(:error_reported).and_return('Error!')
        allow(statement).to receive(:reported_at).and_return(Time.zone.now)
        allow(statement).to receive(:person_item).and_return('Q1')
      end

      include_examples 'classified as', 'manually_actionable'
    end

    context 'when statement has been actioned by has no matching Wikidata P39' do
      let(:position_held_data) { [] }

      before do
        statement.verifications.build(status: true)
        allow(statement).to receive(:person_item).and_return('Q1')
        allow(statement).to receive(:actioned_at).and_return(5.minutes.ago)
        allow(statement).to receive(:actioned_at?).and_return(true)
      end

      include_examples 'classified as', 'manually_actionable'
    end

    context 'when statement is actionable, but has been actioned in the last 5 minutes' do
      around { |example| freeze_time { example.run } }

      before do
        position_held.group = nil
        allow(statement).to receive(:person_item).and_return('Q1')
        allow(statement).to receive(:actioned_at).and_return((5.minutes - 1.second).ago)
        allow(statement).to receive(:actioned_at?).and_return(true)
      end

      include_examples 'classified as', 'done'
    end

    context 'when the statement has been actioned' do
      let(:exact_matches) { ['UUID'] }

      before do
        statement.verifications.build(status: true)
        allow(statement).to receive(:person_item).and_return('Q1')
      end

      include_examples 'classified as', 'done'
    end

    context 'when the reconciled person has since been merged into someone else' do
      let(:exact_matches) { ['UUID'] }

      # Let's assume that Q1 was merged into Q200, so the position
      # held data (from the SPARQL query in the real situation)
      # includes person: Q200 but also merged_then_deleted: Q1. That
      # position data should still be detected as associated with Q1,
      # so the statement will be in "done".
      let(:wikidata_data) do
        { person:              'Q200',
          merged_then_deleted: 'http://www.wikidata.org/entity/Q1111 http://www.wikidata.org/entity/Q1',
          term:                'Q2',
          term_start:          '2018-01-01',
          position_start:      '2018-01-01',
          group:               'Q3',
          district:            'Q4', }
      end

      before do
        statement.verifications.build(status: true)
        allow(statement).to receive(:person_item).and_return('Q1')
      end

      include_examples 'classified as', 'done'
    end

    context 'when the statement is not from suggestions-store and is already correct in Wikidata' do
      let(:exact_matches) { ['UUID'] }

      let(:page) do
        build(:page, csv_source_url: 'http://example.com/politicians.csv')
      end

      before do
        allow(statement).to receive(:person_item).and_return('Q1')
      end

      include_examples 'classified as', 'done'
    end

    context "when the Wikidata item has no district and the statement's page has executive_position = true set" do
      let(:exact_matches) { ['UUID'] }

      let(:page) do
        build(:page, executive_position: true)
      end

      let(:wikidata_data) do
        { person:              'Q1',
          merged_then_deleted: '',
          term:                'Q2',
          term_start:          '2018-01-01',
          position_start:      '2018-01-01',
          group:               'Q3',
          district:            nil, }
      end

      before do
        allow(statement).to receive(:person_item).and_return('Q1')
      end

      include_examples 'classified as', 'done'
    end

    context "when the Wikidata item has no group and the statement's page has executive_position = true set" do
      let(:exact_matches) { ['UUID'] }

      let(:page) do
        build(:page, executive_position: true)
      end

      let(:wikidata_data) do
        { person:              'Q1',
          merged_then_deleted: '',
          term:                'Q2',
          term_start:          '2018-01-01',
          position_start:      '2018-01-01',
          group:               nil,
          district:            'Q4', }
      end

      before do
        allow(statement).to receive(:person_item).and_return('Q1')
      end

      include_examples 'classified as', 'done'
    end

    context 'when statement has no parliamentary group but Wikidata does and everything else matches' do
      let(:exact_matches) { ['UUID'] }

      let(:page) do
        build(:page, csv_source_url: 'http://example.com/politicians.csv')
      end

      let(:data) do
        { person_item:             'Q1',
          electoral_district_item: 'Q4', }
      end

      let(:wikidata_data) do
        { person:              'Q1',
          merged_then_deleted: '',
          term:                'Q2',
          term_start:          '2018-01-01',
          position_start:      '2018-01-01',
          group:               'Q3',
          district:            'Q4', }
      end

      include_examples 'classified as', 'done'
    end

    context 'when statement has no district but Wikidata does and everything else matches' do
      let(:exact_matches) { ['UUID'] }

      let(:page) do
        build(:page, csv_source_url: 'http://example.com/politicians.csv')
      end

      let(:data) do
        { person_item:              'Q1',
          parliamentary_group_item: 'Q3',
          electoral_district_item:  nil, }
      end

      let(:wikidata_data) do
        { person:              'Q1',
          merged_then_deleted: '',
          term:                'Q2',
          term_start:          '2018-01-01',
          position_start:      '2018-01-01',
          group:               'Q3',
          district:            'Q4', }
      end

      include_examples 'classified as', 'done'
    end

    context 'when statement page has no term and everything else matches' do
      let(:exact_matches) { ['UUID'] }

      let(:page) do
        build(:page, csv_source_url: 'http://example.com/politicians.csv')
      end

      let(:data) do
        { person_item:              'Q1',
          parliamentary_group_item: 'Q3',
          electoral_district_item:  nil, }
      end

      let(:wikidata_data) do
        { person:              'Q1',
          merged_then_deleted: '',
          term:                '',
          term_start:          '',
          position_start:      '2018-01-01',
          group:               'Q3',
          district:            'Q4', }
      end

      before do
        statement.verifications.build(status: true)
      end

      include_examples 'classified as', 'done'
    end

    context 'when statement would be actionable, but has been actioned over 5 minutes ago' do
      let(:partial_matches) { ['UUID'] }

      around { |example| freeze_time { example.run } }

      before do
        position_held.group = nil
        allow(statement).to receive(:person_item).and_return('Q1')
        allow(statement).to receive(:actioned_at).and_return(5.minutes.ago)
        allow(statement).to receive(:actioned_at?).and_return(true)
      end

      include_examples 'classified as', 'reverted'
    end

    context 'when statement is done but has been removed from source' do
      let(:exact_matches) { ['UUID'] }

      before do
        statement.removed_from_source = true
        statement.verifications.build(status: true)
        allow(statement).to receive(:person_item).and_return('Q1')
      end

      include_examples 'classified as', 'removed'
    end

    context 'when statement is reverted but has been removed from source' do
      let(:partial_matches) { ['UUID'] }

      before do
        statement.removed_from_source = true
        position_held.group = nil
        allow(statement).to receive(:person_item).and_return('Q1')
        allow(statement).to receive(:actioned_at).and_return(5.minutes.ago)
        allow(statement).to receive(:actioned_at?).and_return(true)
      end

      include_examples 'classified as', 'removed'
    end

    context 'when statement has been remvoed from source before being verified' do
      before { statement.removed_from_source = true }
      include_examples 'classified as', nil # not classified at all
    end

    context 'when there are not any statements' do
      let(:statement) { nil }
      include_examples 'classified as', nil # not classified at all
    end
  end
end

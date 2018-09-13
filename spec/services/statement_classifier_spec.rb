# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatementClassifier, type: :service do
  include ActiveSupport::Testing::TimeHelpers

  let(:page) do
    build(
      :page,
      parliamentary_term_item: 'Q2',
      csv_source_url:          "#{ENV.fetch('SUGGESTIONS_STORE_URL')}/export/ca.csv"
    )
  end

  let(:data) { { person_item: 'Q1' } }
  let(:statement) { build(:statement, data.merge(page: page)) }
  let(:statements) { [statement].compact }
  let(:statement_relation) { double(:relation, to_a: statements) }

  let(:wikidata_data) { { person: 'Q1' } }
  let(:position_held) { OpenStruct.new(wikidata_data) }
  let(:position_held_data) { [position_held] }

  let(:classifier) { StatementClassifier.new('page_title') }

  before do
    allow(statement_relation).to receive_message_chain(
      :original, :includes, :references, :order
    ).and_return(statement_relation)
    allow(Page).to receive(:find_by!)
      .with(title: 'page_title')
      .and_return(page)
    allow(page).to receive(:statements)
      .and_return(statement_relation)
    allow(RetrievePositionData).to receive(:run)
      .with(page.position_held_item, page.parliamentary_term_item, nil)
      .and_return(position_held_data)
  end

  describe 'initialisation' do
    it 'assigns instance variables' do
      expect(classifier.page).to eq page
      expect(classifier.statements).to eq statement_relation
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
      it { expect(classifier.verifiable).to eq(statements) }
      it { expect(classifier.unverifiable).to be_empty }
      it { expect(classifier.reconcilable).to be_empty }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manually_actionable).to be_empty }
      it { expect(classifier.done).to be_empty }
      it { expect(classifier.reverted).to be_empty }
    end

    context 'when unverifiable' do
      before do
        statement.verifications.build(status: false)
      end
      it { expect(classifier.verifiable).to be_empty }
      it { expect(classifier.unverifiable).to eq(statements) }
      it { expect(classifier.reconcilable).to be_empty }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manually_actionable).to be_empty }
      it { expect(classifier.done).to be_empty }
      it { expect(classifier.reverted).to be_empty }
    end

    context 'when unverifiable (although otherwise would be marked "manually actionable")' do
      before do
        statement.verifications.build(status: false)
        allow(statement).to receive(:person_item).and_return('Q1')
        position_held.district = 'other-district'
      end
      it { expect(classifier.verifiable).to be_empty }
      it { expect(classifier.unverifiable).to eq(statements) }
      it { expect(classifier.reconcilable).to be_empty }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manually_actionable).to be_empty }
      it { expect(classifier.done).to be_empty }
      it { expect(classifier.reverted).to be_empty }
    end

    context 'when verified' do
      before { statement.verifications.build(status: true) }
      it { expect(classifier.verifiable).to be_empty }
      it { expect(classifier.unverifiable).to be_empty }
      it { expect(classifier.reconcilable).to eq(statements) }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manually_actionable).to be_empty }
      it { expect(classifier.done).to be_empty }
      it { expect(classifier.reverted).to be_empty }
    end

    context 'when statement is actionable' do
      before do
        position_held.group = nil
        statement.verifications.build(status: true)
        allow(statement).to receive(:person_item).and_return('Q1')
      end
      it { expect(classifier.verifiable).to be_empty }
      it { expect(classifier.unverifiable).to be_empty }
      it { expect(classifier.reconcilable).to be_empty }
      it { expect(classifier.actionable).to eq(statements) }
      it { expect(classifier.manually_actionable).to be_empty }
      it { expect(classifier.done).to be_empty }
      it { expect(classifier.reverted).to be_empty }
    end

    context 'when statement is actionable, but has been actioned in the last 5 minutes' do
      before do
        supposed_current_time = DateTime.new(2018, 6, 6, 15, 1, 1)
        travel_to supposed_current_time
        # 3 minutes before that:
        supposed_actioned_at_time = supposed_current_time - 3.0 / (24 * 60)
        position_held.group = nil
        allow(statement).to receive(:person_item).and_return('Q1')
        allow(statement).to receive(:actioned_at).and_return(supposed_actioned_at_time)
        allow(statement).to receive(:actioned_at?).and_return(true)
      end
      after do
        travel_back
      end
      it { expect(classifier.verifiable).to be_empty }
      it { expect(classifier.unverifiable).to be_empty }
      it { expect(classifier.reconcilable).to be_empty }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manually_actionable).to be_empty }
      it { expect(classifier.done).to eq(statements) }
      it { expect(classifier.reverted).to be_empty }
    end

    context 'when statement would be actionable, but has been actioned over 5 minutes ago' do
      before do
        supposed_current_time = DateTime.new(2018, 6, 6, 15, 1, 1)
        travel_to supposed_current_time
        # 10 minutes before that:
        supposed_actioned_at_time = supposed_current_time - 10.0 / (24 * 60)
        position_held.group = nil
        allow(statement).to receive(:person_item).and_return('Q1')
        allow(statement).to receive(:actioned_at).and_return(supposed_actioned_at_time)
        allow(statement).to receive(:actioned_at?).and_return(true)
      end
      after do
        travel_back
      end
      it { expect(classifier.verifiable).to be_empty }
      it { expect(classifier.unverifiable).to be_empty }
      it { expect(classifier.reconcilable).to be_empty }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manually_actionable).to be_empty }
      it { expect(classifier.done).to be_empty }
      it { expect(classifier.reverted).to eq(statements) }
    end

    context 'when district qualifier contradict' do
      before do
        position_held.district = 'other-district'
        allow(statement).to receive(:person_item).and_return('Q1')
      end
      it { expect(classifier.verifiable).to be_empty }
      it { expect(classifier.unverifiable).to be_empty }
      it { expect(classifier.reconcilable).to be_empty }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manually_actionable).to eq(statements) }
      it { expect(classifier.done).to be_empty }
      it { expect(classifier.reverted).to be_empty }
    end

    context 'when group qualifier contradict' do
      before do
        position_held.group = 'other-group'
        allow(statement).to receive(:person_item).and_return('Q1')
      end
      it { expect(classifier.verifiable).to be_empty }
      it { expect(classifier.unverifiable).to be_empty }
      it { expect(classifier.reconcilable).to be_empty }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manually_actionable).to eq(statements) }
      it { expect(classifier.done).to be_empty }
      it { expect(classifier.reverted).to be_empty }
    end

    context 'when position start is more than 31 days before term start' do
      before do
        position_held.group = nil
        position_held.position_start = '2017-11-05'
        allow(statement).to receive(:person_item).and_return('Q1')
      end
      it { expect(classifier.verifiable).to be_empty }
      it { expect(classifier.unverifiable).to be_empty }
      it { expect(classifier.reconcilable).to be_empty }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manually_actionable).to eq(statements) }
      it { expect(classifier.done).to be_empty }
      it { expect(classifier.reverted).to be_empty }
    end

    context 'when statement has been reported' do
      before do
        allow(statement).to receive(:error_reported).and_return('Error!')
        allow(statement).to receive(:reported_at).and_return(Time.zone.now)
        allow(statement).to receive(:person_item).and_return('Q1')
      end
      it { expect(classifier.verifiable).to be_empty }
      it { expect(classifier.unverifiable).to be_empty }
      it { expect(classifier.reconcilable).to be_empty }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manually_actionable).to eq(statements) }
      it { expect(classifier.done).to be_empty }
      it { expect(classifier.reverted).to be_empty }
    end

    context 'when statement has been actioned by has no matching Wikidata P39' do
      let(:position_held_data) { [] }
      before do
        statement.verifications.build(status: true)
        allow(statement).to receive(:person_item).and_return('Q1')
        allow(statement).to receive(:actioned_at?).and_return(true)
      end
      it { expect(classifier.verifiable).to be_empty }
      it { expect(classifier.unverifiable).to be_empty }
      it { expect(classifier.reconcilable).to be_empty }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manually_actionable).to eq(statements) }
      it { expect(classifier.done).to be_empty }
      it { expect(classifier.reverted).to be_empty }
    end

    context 'when the statement has been actioned' do
      before do
        statement.verifications.build(status: true)
        allow(statement).to receive(:person_item).and_return('Q1')
      end
      it { expect(classifier.verifiable).to be_empty }
      it { expect(classifier.unverifiable).to be_empty }
      it { expect(classifier.reconcilable).to be_empty }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manually_actionable).to be_empty }
      it { expect(classifier.done).to eq(statements) }
      it { expect(classifier.reverted).to be_empty }
    end

    context 'when there are not any statements' do
      let(:statement) { nil }
      it { expect(classifier.verifiable).to be_empty }
      it { expect(classifier.unverifiable).to be_empty }
      it { expect(classifier.reconcilable).to be_empty }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manually_actionable).to be_empty }
      it { expect(classifier.done).to be_empty }
      it { expect(classifier.reverted).to be_empty }
    end

    context 'when the reconciled person has since been merged into someone else' do
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
      it { expect(classifier.verifiable).to be_empty }
      it { expect(classifier.unverifiable).to be_empty }
      it { expect(classifier.reconcilable).to be_empty }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manually_actionable).to be_empty }
      it { expect(classifier.done).to eq(statements) }
      it { expect(classifier.reverted).to be_empty }
    end

    context 'when the statements are reconciled but not verified' do
      before do
        allow(statement).to receive(:person_item).and_return('Q1')
      end
      it { expect(classifier.verifiable).to eq(statements) }
      it { expect(classifier.unverifiable).to be_empty }
      it { expect(classifier.reconcilable).to be_empty }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manually_actionable).to be_empty }
      it { expect(classifier.done).to be_empty }
      it { expect(classifier.reverted).to be_empty }
    end

    context 'when the statement is from suggestions-store and is already correct (apart from the reference) in Wikidata' do
      before do
        allow(statement).to receive(:person_item).and_return('Q1')
      end
      it { expect(classifier.verifiable).to eq(statements) }
      it { expect(classifier.unverifiable).to be_empty }
      it { expect(classifier.reconcilable).to be_empty }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manually_actionable).to be_empty }
      it { expect(classifier.done).to be_empty }
      it { expect(classifier.reverted).to be_empty }
    end

    context 'when the statement is not from suggestions-store and is already correct in Wikidata' do
      let(:page) do
        build(:page, parliamentary_term_item: 'Q2', csv_source_url: 'http://example.com/politicians.csv')
      end
      before do
        allow(statement).to receive(:person_item).and_return('Q1')
      end
      it { expect(classifier.verifiable).to be_empty }
      it { expect(classifier.unverifiable).to be_empty }
      it { expect(classifier.reconcilable).to be_empty }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manually_actionable).to be_empty }
      it { expect(classifier.done).to eq(statements) }
      it { expect(classifier.reverted).to be_empty }
    end

    context "when the Wikidata item has no district and the statement's page has executive_position = true set" do
      let(:page) do
        build(:page, parliamentary_term_item: 'Q2', executive_position: true)
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
      it { expect(classifier.verifiable).to be_empty }
      it { expect(classifier.unverifiable).to be_empty }
      it { expect(classifier.reconcilable).to be_empty }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manually_actionable).to be_empty }
      it { expect(classifier.done).to eq(statements) }
      it { expect(classifier.reverted).to be_empty }
    end

    context "when the Wikidata item has no group and the statement's page has executive_position = true set" do
      let(:page) do
        build(:page, parliamentary_term_item: 'Q2', executive_position: true)
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
      it { expect(classifier.verifiable).to be_empty }
      it { expect(classifier.unverifiable).to be_empty }
      it { expect(classifier.reconcilable).to be_empty }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manually_actionable).to be_empty }
      it { expect(classifier.done).to eq(statements) }
      it { expect(classifier.reverted).to be_empty }
    end

    context 'when statement has no parliamentary group but Wikidata does and everything else matches' do
      let(:page) do
        build(:page, parliamentary_term_item: 'Q2', csv_source_url: 'http://example.com/politicians.csv')
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
      it { expect(classifier.verifiable).to be_empty }
      it { expect(classifier.unverifiable).to be_empty }
      it { expect(classifier.reconcilable).to be_empty }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manually_actionable).to be_empty }
      it { expect(classifier.done).to eq(statements) }
      it { expect(classifier.reverted).to be_empty }
    end

    context 'when statement has no district but Wikidata does and everything else matches' do
      let(:page) do
        build(:page, parliamentary_term_item: 'Q2', csv_source_url: 'http://example.com/politicians.csv')
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
      it { expect(classifier.verifiable).to be_empty }
      it { expect(classifier.unverifiable).to be_empty }
      it { expect(classifier.reconcilable).to be_empty }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manually_actionable).to be_empty }
      it { expect(classifier.done).to eq(statements) }
      it { expect(classifier.reverted).to be_empty }
    end

    context 'when statement page has no term and everything else matches' do
      let(:page) do
        build(:page, parliamentary_term_item: '', csv_source_url: 'http://example.com/politicians.csv')
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
        allow(statement).to receive(:actioned_at).and_return(Time.now - 10.minutes)
        allow(statement).to receive(:actioned_at?).and_return(true)
      end
      it { expect(classifier.verifiable).to be_empty }
      it { expect(classifier.unverifiable).to be_empty }
      it { expect(classifier.reconcilable).to be_empty }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manually_actionable).to be_empty }
      it { expect(classifier.done).to eq(statements) }
      it { expect(classifier.reverted).to be_empty }
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatementClassifier, type: :service do
  let(:page) do
    double(:page, statements: statement_relation, position_held_item: 'Q2')
  end

  let(:data) { { person_item: 'Q1' } }
  let(:statement) { Statement.new(data) }
  let(:statements) { [statement].compact }
  let(:statement_relation) { double(:relation, to_a: statements) }

  let(:wikidata_data) { { person: 'Q1' } }
  let(:position_held) { OpenStruct.new(wikidata_data) }
  let(:position_held_data) { [position_held] }

  let(:classifier) { StatementClassifier.new('page_title') }

  before do
    allow(statement_relation).to receive_message_chain(
      :original, :includes, :references, :order).and_return(statement_relation)
    allow(Page).to receive(:find_by!)
      .with(title: 'page_title')
      .and_return(page)
    allow(RetrievePositionData).to receive(:run)
      .with(page.position_held_item, nil)
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
      { person_item: '',
        page: Page.new(parliamentary_term_item: 'Q2'),
        parliamentary_group_item: 'Q3',
        electoral_district_item: 'Q4' }
    end

    let(:wikidata_data) do
      { person: 'Q1',
        term: 'Q2',
        start_of_term: '2018-01-01',
        start_date: '2018-01-01',
        group: 'Q3',
        district: 'Q4' }
    end

    context 'when verifiable' do
      it { expect(classifier.verifiable).to eq(statements) }
      it { expect(classifier.unverifiable).to be_empty }
      it { expect(classifier.reconcilable).to be_empty }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manually_actionable).to be_empty }
      it { expect(classifier.done).to be_empty }
    end

    context 'when unverifiable' do
      before { statement.verifications.build(status: false) }
      it { expect(classifier.verifiable).to be_empty }
      it { expect(classifier.unverifiable).to eq(statements) }
      it { expect(classifier.reconcilable).to be_empty }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manually_actionable).to be_empty }
      it { expect(classifier.done).to be_empty }
    end

    context 'when verified' do
      before { statement.verifications.build(status: true) }
      it { expect(classifier.verifiable).to be_empty }
      it { expect(classifier.unverifiable).to be_empty }
      it { expect(classifier.reconcilable).to eq(statements) }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manually_actionable).to be_empty }
      it { expect(classifier.done).to be_empty }
    end

    context 'when statement is actionable' do
      before do
        position_held.group = nil
        allow(statement).to receive(:person_item).and_return('Q1')
      end
      it { expect(classifier.verifiable).to be_empty }
      it { expect(classifier.unverifiable).to be_empty }
      it { expect(classifier.reconcilable).to be_empty }
      it { expect(classifier.actionable).to eq(statements) }
      it { expect(classifier.manually_actionable).to be_empty }
      it { expect(classifier.done).to be_empty }
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
    end

    context 'when position start is 2 days before term start' do
      before do
        position_held.group = nil
        position_held.start_date = '2017-12-30'
        allow(statement).to receive(:person_item).and_return('Q1')
      end
      it { expect(classifier.verifiable).to be_empty }
      it { expect(classifier.unverifiable).to be_empty }
      it { expect(classifier.reconcilable).to be_empty }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manually_actionable).to eq(statements) }
      it { expect(classifier.done).to be_empty }
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
    end


    context 'when there are not any statements' do
      let(:statement) { nil }
      it { expect(classifier.verifiable).to be_empty }
      it { expect(classifier.unverifiable).to be_empty }
      it { expect(classifier.reconcilable).to be_empty }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manually_actionable).to be_empty }
      it { expect(classifier.done).to be_empty }
    end
  end
end

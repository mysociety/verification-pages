# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatementClassifier, type: :service do
  let(:page) { double(:page, statements: statements, position_held_item: 'Q2') }

  let(:data) { { person_item: 'Q1' } }
  let(:statement) { Statement.new(data) }
  let(:statements) { [statement].compact }

  let(:wikidata_data) { { person: 'Q1' } }
  let(:position_held) { OpenStruct.new(wikidata_data) }
  let(:position_held_data) { [position_held] }

  let(:classifier) { StatementClassifier.new('page_title') }

  before do
    allow(Page).to receive(:find_by!)
      .with(title: 'page_title')
      .and_return(page)
    allow(RetrievePositionData).to receive(:run)
      .with(page.position_held_item)
      .and_return(position_held_data)
  end

  describe 'initialisation' do
    it 'assigns instance variables' do
      expect(classifier.page).to eq page
      expect(classifier.statements).to eq statements
    end
  end

  describe 'statement classification' do
    let(:data) do
      { person_item: 'Q1',
        parliamentary_term_item: 'Q2',
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

    context 'when actionable' do
      it { expect(classifier.actionable).to eq(statements) }
      it { expect(classifier.manual).to be_empty }
      it { expect(classifier.evidenced).to be_empty }
    end

    context 'when district qualifier contradict' do
      before { position_held.district = 'other-district' }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manual).to eq(statements) }
      it { expect(classifier.evidenced).to be_empty }
    end

    context 'when group qualifier contradict' do
      before { position_held.group = 'other-group' }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manual).to eq(statements) }
      it { expect(classifier.evidenced).to be_empty }
    end

    context 'when position start is 2 days before term start' do
      before { position_held.start_date = '2017-12-30' }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manual).to eq(statements) }
      it { expect(classifier.evidenced).to be_empty }
    end

    context 'when result is positive' do
      before { statement.results.build(status: :yes) }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manual).to be_empty }
      it { expect(classifier.evidenced).to eq(statements) }
    end

    context 'when result is negative' do
      before { statement.results.build(status: :no) }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manual).to be_empty }
      it { expect(classifier.evidenced).to be_empty }
    end

    context 'when terms do not match' do
      before { position_held.term = 'other-term' }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manual).to be_empty }
      it { expect(classifier.evidenced).to be_empty }
    end

    context 'when there are not any statements' do
      let(:statement) { nil }
      it { expect(classifier.actionable).to be_empty }
      it { expect(classifier.manual).to be_empty }
      it { expect(classifier.evidenced).to be_empty }
    end
  end
end

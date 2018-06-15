# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatementDecorator, type: :decorator do
  let(:object) { Statement.new(person_item: 'Q1') }
  let(:matching_position_held_data) do
    [ OpenStruct.new(revision: '123', position: 'UUID') ]
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

  context 'when electoral districts contradict' do
    let(:object) do
      Statement.new(
        person_item: 'Q1',
        electoral_district_item: 'Q789',
      )
    end
    let(:matching_position_held_data) do
      [ OpenStruct.new(revision: '123', position: 'UUID', district: 'Q345') ]
    end
    let(:expected_error) do
      'The electoral district is different in the statement (Q789) and on Wikidata (Q345)'
    end
    it 'should find a problem with the electoral districts' do
      expect(statement.electoral_district_problems).to eq([ expected_error ])
    end
    it 'should find a problem overall' do
      expect(statement.problems).to eq([ expected_error ])
    end
  end

  context 'when parliamentary groups (parties) contradict' do
    let(:object) do
      Statement.new(
        person_item: 'Q1',
        parliamentary_group_item: 'Q123',
      )
    end
    let(:matching_position_held_data) do
      [ OpenStruct.new(revision: '123', position: 'UUID', group: 'Q234') ]
    end
    let(:expected_error) do
      'The parliamentary group (party) is different in the statement (Q123) and on Wikidata (Q234)'
    end
    it 'should find a problem with the parliamentary groups' do
      expect(statement.parliamentary_group_problems).to eq([ expected_error ])
    end
    it 'should find a problem overall' do
      expect(statement.problems).to eq([ expected_error ])
    end
  end

  context 'when the position start date on Wikidata is more than 1 day before the start of the term' do
    let(:matching_position_held_data) do
      [
        OpenStruct.new(
          revision: '123',
          position: 'UUID',
          start_date: '2014-01-06',
          start_of_term: '2014-01-31'
        )
      ]
    end
    let(:expected_error) do
      'On Wikidata, the position held start date (2014-01-06) was before the term start date (2014-01-31)'
    end
    it 'should find a problem with the start date' do
      expect(statement.start_date_before_term_problems).to eq([ expected_error ])
    end
    it 'should find a problem overall' do
      expect(statement.problems).to eq([ expected_error ])
    end
  end

  context 'when the position start date on Wikidata is the day before the start of the term' do
    let(:matching_position_held_data) do
      [
        OpenStruct.new(
          revision: '123',
          position: 'UUID',
          start_date: '2014-01-06',
          start_of_term: '2014-01-07'
        )
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
          revision: '123',
          position: 'UUID',
          start_date: '2014-01-06',
          start_of_term: '2014-01-04'
        )
      ]
    end
    it 'should find no problem with the start date' do
      expect(statement.start_date_before_term_problems).to be_empty
    end
    it 'should find no problems overall' do
      expect(statement.problems).to be_empty
    end
  end

  context 'when all known problems happen for the same data' do
    let(:object) do
      Statement.new(
        person_item: 'Q1',
        parliamentary_group_item: 'Q123',
        electoral_district_item: 'Q789',
      )
    end
    let(:matching_position_held_data) do
      [
        OpenStruct.new(
          revision: '123',
          position: 'UUID',
          start_date: '2014-01-06',
          start_of_term: '2014-01-31',
          district: 'Q345',
          group: 'Q234'
        )
      ]
    end
    it 'should report all those problems' do
      expected_errors =[
        "The electoral district is different in the statement (Q789) and on Wikidata (Q345)",
        "The parliamentary group (party) is different in the statement (Q123) and on Wikidata (Q234)",
        "On Wikidata, the position held start date (2014-01-06) was before the term start date (2014-01-31)"
      ]
      expect(statement.problems).to eq(expected_errors)
    end
  end
end

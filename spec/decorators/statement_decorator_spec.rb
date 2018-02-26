# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatementDecorator, type: :decorator do
  let(:object) { Statement.new(person_item: 'Q1') }
  let(:position_held_data) do
    OpenStruct.new(revision: '123', position: 'UUID')
  end
  let(:statement) { StatementDecorator.new(object, position_held_data) }

  describe 'initialisation' do
    it 'does not replace existing values' do
      expect(statement.person_item).to eq 'Q1'
    end

    it 'updates missing values' do
      expect(statement.person_revision).to eq '123'
      expect(statement.statement_uuid).to eq 'UUID'
    end
  end
end

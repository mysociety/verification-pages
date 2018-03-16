# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Statement, type: :model do
  let(:statement) { Statement.new }

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
end

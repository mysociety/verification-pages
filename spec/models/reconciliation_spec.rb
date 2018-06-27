# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reconciliation, type: :model do
  let(:reconciliation) { Reconciliation.new }

  describe 'associations' do
    it 'belong to statement' do
      expect(reconciliation.build_statement).to be_a(Statement)
    end
  end

  describe 'validations' do
    before { reconciliation.valid? }

    it 'requires item' do
      expect(reconciliation.errors).to include(:item)
    end

    it 'requires resource_type' do
      expect(reconciliation.errors).to include(:resource_type)
    end
  end

  describe 'after commit callback' do
    let(:statement) { create(:statement) }

    before do
      allow(reconciliation).to receive(:statement).and_return(statement)
    end

    context 'person resource_type' do
      before { reconciliation.resource_type = 'person' }

      it 'updates statement person item' do
        expect(statement).to receive(:update_attributes)
          .with(person_item: 'Q2').once
        reconciliation.item = 'Q2'
        reconciliation.save! # create

        expect(statement).to receive(:update_attributes)
          .with(person_item: 'Q3').once
        reconciliation.item = 'Q3'
        reconciliation.save! # update
      end
    end

    context 'party resource_type' do
      before { reconciliation.resource_type = 'party' }

      it 'updates statement parlimentary group item' do
        expect(statement).to receive(:update_attributes)
          .with(parliamentary_group_item: 'Q2').once
        reconciliation.item = 'Q2'
        reconciliation.save! # create

        expect(statement).to receive(:update_attributes)
          .with(parliamentary_group_item: 'Q3').once
        reconciliation.item = 'Q3'
        reconciliation.save! # update
      end
    end
  end
end

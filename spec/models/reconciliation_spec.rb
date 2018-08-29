# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reconciliation, type: :model do
  let(:reconciliation) { Reconciliation.new(update_type: 'single') }

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
        expect(statement).to receive(:update)
          .with(person_item: 'Q2').once
        reconciliation.item = 'Q2'
        reconciliation.save! # create

        expect(statement).to receive(:update)
          .with(person_item: 'Q3').once
        reconciliation.item = 'Q3'
        reconciliation.save! # update
      end
    end

    context 'party resource_type' do
      before { reconciliation.resource_type = 'party' }

      it 'updates statement parlimentary group item' do
        expect(statement).to receive(:update)
          .with(parliamentary_group_item: 'Q2').once
        reconciliation.item = 'Q2'
        reconciliation.save! # create

        expect(statement).to receive(:update)
          .with(parliamentary_group_item: 'Q3').once
        reconciliation.item = 'Q3'
        reconciliation.save! # update
      end
    end

    context 'district resource_type' do
      before { reconciliation.resource_type = 'district' }

      it 'updates statement electoral district item' do
        expect(statement).to receive(:update)
          .with(electoral_district_item: 'Q5').once
        reconciliation.item = 'Q5'
        reconciliation.save! # create

        expect(statement).to receive(:update)
          .with(electoral_district_item: 'Q6').once
        reconciliation.item = 'Q6'
        reconciliation.save! # update
      end
    end

    context 'the update_type is also_matching_unreconciled' do
      before { reconciliation.update_type = 'also_matching_unreconciled' }

      context 'person resource_type' do
        before { reconciliation.resource_type = 'person' }

        let(:statement) do
          create(:statement, person_name: 'Joe Bloggs', transaction_id: '124')
        end
        let!(:statement_unreconciled) do
          create(:statement, person_name: 'Joe Bloggs', transaction_id: '125', page: statement.page)
        end
        let!(:statement_reconciled_to_different_item) do
          create(:statement, person_name: 'Joe Bloggs', transaction_id: '126', page: statement.page, person_item: 'Q7323')
        end

        it 'should only update the particular statement' do
          expect(statement).to receive(:update)
            .with(person_item: 'Q123').once
          reconciliation.item = 'Q123'
          reconciliation.save!
          statement_unreconciled.reload
          expect(statement_unreconciled.person_item).to be_nil
          statement_reconciled_to_different_item.reload
          expect(statement_reconciled_to_different_item.person_item).to eq('Q7323')
        end
      end

      context 'party resource_type' do
        before { reconciliation.resource_type = 'party' }

        let(:statement) do
          create(:statement, parliamentary_group_name: 'OMRLP', transaction_id: '124')
        end
        let!(:statement_unreconciled) do
          create(:statement, parliamentary_group_name: 'OMRLP', transaction_id: '125', page: statement.page)
        end
        let!(:statement_reconciled_to_different_item) do
          create(:statement, parliamentary_group_name: 'OMRLP', transaction_id: '126', page: statement.page, parliamentary_group_item: 'Q137')
        end

        it 'should update the original statement and the unreconciled one, but not one matched to a different item' do
          expect(statement).to receive(:update)
            .with(parliamentary_group_item: 'Q135').once
          reconciliation.item = 'Q135'
          reconciliation.save!
          statement_unreconciled.reload
          expect(statement_unreconciled.parliamentary_group_item).to eq('Q135')
          statement_reconciled_to_different_item.reload
          expect(statement_reconciled_to_different_item.parliamentary_group_item).to eq('Q137')
        end
      end

      context 'district resource_type' do
        before { reconciliation.resource_type = 'district' }

        let(:statement) do
          create(:statement, electoral_district_name: 'OMRLP', transaction_id: '124')
        end
        let!(:statement_unreconciled) do
          create(:statement, electoral_district_name: 'OMRLP', transaction_id: '125', page: statement.page)
        end
        let!(:statement_reconciled_to_different_item) do
          create(:statement, electoral_district_name: 'OMRLP', transaction_id: '126', page: statement.page, electoral_district_item: 'Q137')
        end

        it 'should update the original statement and the unreconciled one, but not one matched to a different item' do
          expect(statement).to receive(:update)
            .with(electoral_district_item: 'Q135').once
          reconciliation.item = 'Q135'
          reconciliation.save!
          statement_unreconciled.reload
          expect(statement_unreconciled.electoral_district_item).to eq('Q135')
          statement_reconciled_to_different_item.reload
          expect(statement_reconciled_to_different_item.electoral_district_item).to eq('Q137')
        end
      end
    end

    context 'the update_type is also_matching' do
      before { reconciliation.update_type = 'also_matching' }
      context 'person resource_type' do
        before { reconciliation.resource_type = 'person' }

        let(:statement) do
          create(:statement, person_name: 'Joe Bloggs', transaction_id: '124')
        end
        let!(:statement_unreconciled) do
          create(:statement, person_name: 'Joe Bloggs', transaction_id: '125', page: statement.page)
        end
        let!(:statement_reconciled_to_different_item) do
          create(:statement, person_name: 'Joe Bloggs', transaction_id: '126', page: statement.page, person_item: 'Q7323')
        end

        it 'should only update the particular statement' do
          expect(statement).to receive(:update)
            .with(person_item: 'Q123').once
          reconciliation.item = 'Q123'
          reconciliation.save!
          statement_unreconciled.reload
          expect(statement_unreconciled.person_item).to be_nil
          statement_reconciled_to_different_item.reload
          expect(statement_reconciled_to_different_item.person_item).to eq('Q7323')
        end
      end

      context 'party resource_type' do
        before { reconciliation.resource_type = 'party' }

        let(:statement) do
          create(:statement, parliamentary_group_name: 'OMRLP', transaction_id: '124')
        end
        let!(:statement_unreconciled) do
          create(:statement, parliamentary_group_name: 'OMRLP', transaction_id: '125', page: statement.page)
        end
        let!(:statement_reconciled_to_different_item) do
          create(:statement, parliamentary_group_name: 'OMRLP', transaction_id: '126', page: statement.page, parliamentary_group_item: 'Q137')
        end

        it 'should update the original statement and the unreconciled one, but not one matched to a different item' do
          expect(statement).to receive(:update)
            .with(parliamentary_group_item: 'Q135').once
          reconciliation.item = 'Q135'
          reconciliation.save!
          statement_unreconciled.reload
          expect(statement_unreconciled.parliamentary_group_item).to eq('Q135')
          statement_reconciled_to_different_item.reload
          expect(statement_reconciled_to_different_item.parliamentary_group_item).to eq('Q135')
        end
      end

      context 'district resource_type' do
        before { reconciliation.resource_type = 'district' }

        let(:statement) do
          create(:statement, electoral_district_name: 'OMRLP', transaction_id: '124')
        end
        let!(:statement_unreconciled) do
          create(:statement, electoral_district_name: 'OMRLP', transaction_id: '125', page: statement.page)
        end
        let!(:statement_reconciled_to_different_item) do
          create(:statement, electoral_district_name: 'OMRLP', transaction_id: '126', page: statement.page, electoral_district_item: 'Q137')
        end

        it 'should update the original statement and the unreconciled one, but not one matched to a different item' do
          expect(statement).to receive(:update)
            .with(electoral_district_item: 'Q135').once
          reconciliation.item = 'Q135'
          reconciliation.save!
          statement_unreconciled.reload
          expect(statement_unreconciled.electoral_district_item).to eq('Q135')
          statement_reconciled_to_different_item.reload
          expect(statement_reconciled_to_different_item.electoral_district_item).to eq('Q135')
        end
      end
    end

    context 'statement has FB identifier' do
      let(:statement) do
        # set initial person_item otherwise statement will attempt to fetch it
        # from ID mapping store
        create(:statement, person_item: 'Q1', fb_identifier: 'ABC')
      end

      before { reconciliation.resource_type = 'person' }

      it 'should create equivalence claim' do
        store = double('IDMappingStore')
        expect(IDMappingStore).to receive(:new)
          .with(wikidata_id: 'Q123', facebook_id: 'ABC')
          .and_return(store)
        expect(store).to receive(:create_equivalence_claim)

        reconciliation.item = 'Q123'
        reconciliation.save!
      end
    end
  end
end

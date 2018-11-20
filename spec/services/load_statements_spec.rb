# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LoadStatements do
  include_context 'id-mapping-store default setup'

  describe '#run' do
    let(:suggestions_store_response) { '' }
    let(:page) { build(:page, csv_source_url: 'http://example.com/export.csv') }

    before do
      allow(Page).to receive(:find_by!).with(title: page.title).and_return(page)
      stub_request(:get, 'http://example.com/export.csv').to_return(status: 200, body: suggestions_store_response, headers: {})
    end

    context 'CSV file with transaction_id' do
      let(:suggestions_store_response) do
        <<~CSV
          transaction_id,person_name,electoral_district_name,electoral_district_item,fb_identifier
          1234,Alice,Ambridge,Q1234,10987654321
          4321,Bob,Bambridge,Q4321,10987654322
        CSV
      end

      before do
        stub_id_mapping_store(scheme_id: '7', identifier: '10987654322')
      end

      let!(:existing_statement) do
        create(:statement, transaction_id: '1234', person_name: 'Arthur', page: page)
      end

      it 'creates a missing statement' do
        load_statements = LoadStatements.new(page.title)
        expect { load_statements.run }.to change(Statement, :count).by(1)
        last_statement = Statement.last
        expect(last_statement.transaction_id).to eq('4321')
        expect(last_statement.person_name).to eq('Bob')
        expect(last_statement.electoral_district_name).to eq('Bambridge')
        expect(last_statement.electoral_district_item).to eq('Q4321')
        expect(last_statement.fb_identifier).to eq('10987654322')
      end

      it 'updates existing statements' do
        load_statements = LoadStatements.new(page.title)
        load_statements.run
        existing_statement.reload
        expect(existing_statement.transaction_id).to eq('1234')
        expect(existing_statement.person_name).to eq('Alice')
        expect(existing_statement.electoral_district_name).to eq('Ambridge')
        expect(existing_statement.electoral_district_item).to eq('Q1234')
        expect(existing_statement.fb_identifier).to eq('10987654321')
      end
    end

    context 'CSV file not from suggestions-store' do
      let(:suggestions_store_response) do
        <<~CSV
          person_name,person_item,electoral_district_name,electoral_district_item,parliamentary_group_name,parliamentary_group_item
          Alice,Q987,Ambridge,Q1234,Aparty,Q555
          Bob,Q876,Bambridge,Q4321,Bparty,Q666
        CSV
      end

      let!(:existing_statement) do
        create(:statement, transaction_id: '1234', person_name: 'Arthur', page: page)
      end

      before do
        allow(page).to receive(:generate_transaction_id).with(
          electoral_district_item: 'Q1234', electoral_district_name: 'Ambridge',
          parliamentary_group_item: 'Q555', parliamentary_group_name: 'Aparty',
          person_item: 'Q987', person_name: 'Alice'
        ).and_return('1234')

        allow(page).to receive(:generate_transaction_id).with(
          electoral_district_item: 'Q4321', electoral_district_name: 'Bambridge',
          parliamentary_group_item: 'Q666', parliamentary_group_name: 'Bparty',
          person_item: 'Q876', person_name: 'Bob'
        ).and_return('4321')
      end

      it 'creates a missing statement' do
        load_statements = LoadStatements.new(page.title)
        expect { load_statements.run }.to change(Statement, :count).by(1)
        last_statement = Statement.last
        expect(last_statement.transaction_id).to eq('4321')
        expect(last_statement.person_name).to eq('Bob')
        expect(last_statement.person_item).to eq('Q876')
        expect(last_statement.electoral_district_name).to eq('Bambridge')
        expect(last_statement.electoral_district_item).to eq('Q4321')
        expect(last_statement.parliamentary_group_name).to eq('Bparty')
        expect(last_statement.parliamentary_group_item).to eq('Q666')
      end

      it 'updates existing statements' do
        load_statements = LoadStatements.new(page.title)
        load_statements.run
        existing_statement.reload
        expect(existing_statement.transaction_id).to eq('1234')
        expect(existing_statement.person_name).to eq('Alice')
        expect(existing_statement.person_item).to eq('Q987')
        expect(existing_statement.electoral_district_name).to eq('Ambridge')
        expect(existing_statement.electoral_district_item).to eq('Q1234')
        expect(existing_statement.parliamentary_group_name).to eq('Aparty')
        expect(existing_statement.parliamentary_group_item).to eq('Q555')
      end
    end

    context 'items have been manually reconciled, but are still empty in the upstream source' do
      let(:suggestions_store_response) do
        <<~CSV
          transaction_id,person_name,person_item,electoral_district_name,electoral_district_item,parliamentary_group_name,parliamentary_group_item
          1234,Alice,,Ambridge,,Aparty,
        CSV
      end

      let!(:existing_statement) do
        create(:statement, transaction_id: '1234', person_name: 'Alice', person_item: 'Q34543', electoral_district_item: 'Q934234', parliamentary_group_item: 'Q234435', page: page)
      end

      it 'should not wipe out the manually reconciled values' do
        load_statements = LoadStatements.new(page.title)
        load_statements.run
        existing_statement.reload
        expect(existing_statement.transaction_id).to eq('1234')
        expect(existing_statement.person_name).to eq('Alice')
        expect(existing_statement.person_item).to eq('Q34543')
        expect(existing_statement.electoral_district_name).to eq('Ambridge')
        expect(existing_statement.electoral_district_item).to eq('Q934234')
        expect(existing_statement.parliamentary_group_name).to eq('Aparty')
        expect(existing_statement.parliamentary_group_item).to eq('Q234435')
      end
    end

    context 'items have been reconciled, but are not empty in the upstream source' do
      let(:suggestions_store_response) do
        <<~CSV
          transaction_id,person_name,person_item,electoral_district_name,electoral_district_item,parliamentary_group_name,parliamentary_group_item
          1234,Alice,Q1,Ambridge,Q2,Aparty,Q3
        CSV
      end

      let!(:existing_statement) do
        create(:statement, transaction_id: '1234', person_name: 'Alice', page: page)
      end

      before do
        existing_statement.reconciliations.create(resource_type: 'person', item: 'Q34543')
        existing_statement.reconciliations.create(resource_type: 'district', item: 'Q934234')
        existing_statement.reconciliations.create(resource_type: 'party', item: 'Q234435')
      end

      it 'should not wipe out the manually reconciled values' do
        load_statements = LoadStatements.new(page.title)
        load_statements.run
        existing_statement.reload
        expect(existing_statement.transaction_id).to eq('1234')
        expect(existing_statement.person_name).to eq('Alice')
        expect(existing_statement.person_item).to eq('Q34543')
        expect(existing_statement.electoral_district_name).to eq('Ambridge')
        expect(existing_statement.electoral_district_item).to eq('Q934234')
        expect(existing_statement.parliamentary_group_name).to eq('Aparty')
        expect(existing_statement.parliamentary_group_item).to eq('Q234435')
      end
    end

    context 'items have been removed from upstream source' do
      let(:suggestions_store_response) do
        <<~CSV
          person_name,person_item,electoral_district_name,electoral_district_item,parliamentary_group_name,parliamentary_group_item
          Alice,Q987,Ambridge,Q1234,Aparty,Q555
        CSV
      end

      let!(:existing_statement) do
        create(:statement, page: page, removed_from_source: false)
      end

      let!(:other_statement) do
        create(:statement, removed_from_source: false)
      end

      before do
        allow(page).to receive(:generate_transaction_id).and_return('1234')
      end

      it 'should mark existing statements as being removed from the source' do
        load_statements = LoadStatements.new(page.title)
        expect { load_statements.run }.to change(page.statements, :count).by(1)
        existing_statement.reload
        expect(existing_statement.removed_from_source).to eq true
      end

      it 'should not mark as removed statements belonging to other pages' do
        load_statements = LoadStatements.new(page.title)
        expect { load_statements.run }.to change(page.statements, :count).by(1)
        other_statement.reload
        expect(other_statement.removed_from_source).to eq false
      end

      it 'returns the active statements' do
        load_statements = LoadStatements.new(page.title)
        result = load_statements.run
        new_statement = Statement.last
        expect(result).to match_array([new_statement])
      end
    end

    context 'items have been updated in upstream source' do
      let(:suggestions_store_response) do
        <<~CSV
          person_name,person_item
          Alice,Q1234
        CSV
      end

      let!(:existing) { create(:statement, person_name: 'Alice', page: page) }
      let(:statement) { Statement.last }

      before do
        load_statements = LoadStatements.new(page.title)
        expect { load_statements.run }.to change(Statement, :count).by(1)
      end

      it 'should replace existing statement' do
        existing.reload
        expect(existing).to be_removed_from_source
      end

      it 'should not mark new statement as a duplicate' do
        expect(statement).to_not be_duplicate
      end
    end

    context 'items alternate columns in upstream source' do
      let(:suggestions_store_response) do
        <<~CSV
          name,id,alliance,wikidata_alliance,constituency,constituency_id
          Alice,Q123,Aparty,Q456,Ambridge,Q789
        CSV
      end

      let(:statement) { Statement.last }

      before do
        load_statements = LoadStatements.new(page.title)
        expect { load_statements.run }.to change(Statement, :count).by(1)
      end

      it 'should map alternate columns' do
        expect(statement.person_name).to eq 'Alice'
        expect(statement.person_item).to eq 'Q123'
        expect(statement.parliamentary_group_name).to eq 'Aparty'
        expect(statement.parliamentary_group_item).to eq 'Q456'
        expect(statement.electoral_district_name).to eq 'Ambridge'
        expect(statement.electoral_district_item).to eq 'Q789'
      end
    end

    context 'use an EveryPolitician CSV as the upstream source' do
      let(:suggestions_store_response) do
        <<~CSV
          id,name,sort_name,email,twitter,facebook,group,group_id,area_id,area,chamber,term,start_date,end_date,image,gender,wikidata,wikidata_group,wikidata_area
          c216f406-b11f-4f2b-a890-e9922293478e,Anthony Martinez,Anthony Martinez,,,,United Democratic Party,90ee4fde-68d6-4544-bb2a-2a58371b629f,7764e1c2-da2a-456f-9ab1-d66665df244d,Port Loyola,House of Representatives,9,,,http://nationalassembly.gov.bz/images/house_of_rep/a_martinez.jpg,male,Q4773030,Q1809323,Q16975862
          5a76ebe1-9913-4008-83fd-f7ea1e95c26a,Dr. Marco Tulio Mendez,Dr. Marco Tulio Mendez,,,,People's United Party,8e327a03-68fd-4ea0-bd59-b59cb05ecfd6,78a91d5b-a813-4367-aab8-cf6aa6934ac1,Orange Walk East,House of Representatives,9,,,http://nationalassembly.gov.bz/images/house_of_rep/marco%20tulio.jpg,male,,Q1759613,Q25405052
        CSV
      end

      let(:statement_1) { Statement.find_by(person_name: 'Anthony Martinez') }
      let(:statement_2) { Statement.find_by(person_name: 'Dr. Marco Tulio Mendez') }

      before do
        load_statements = LoadStatements.new(page.title)
        expect { load_statements.run }.to change(Statement, :count).by(2)
      end

      it 'should map alternate columns' do
        expect(statement_1.person_name).to eq 'Anthony Martinez'
        expect(statement_1.person_item).to eq 'Q4773030'
        expect(statement_1.parliamentary_group_name).to eq 'United Democratic Party'
        expect(statement_1.parliamentary_group_item).to eq 'Q1809323'
        expect(statement_1.electoral_district_name).to eq 'Port Loyola'
        expect(statement_1.electoral_district_item).to eq 'Q16975862'
      end

      it 'should map to nil if alternate columns are invalid' do
        expect(statement_2.person_name).to eq 'Dr. Marco Tulio Mendez'
        expect(statement_2.person_item).to be_nil
        expect(statement_2.parliamentary_group_name).to eq "People's United Party"
        expect(statement_2.parliamentary_group_item).to eq 'Q1759613'
        expect(statement_2.electoral_district_name).to eq 'Orange Walk East'
        expect(statement_2.electoral_district_item).to eq 'Q25405052'
      end
    end
  end
end

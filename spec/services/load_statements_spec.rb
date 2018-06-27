require 'rails_helper'

RSpec.describe LoadStatements do
  include_context 'id-mapping-store default setup'

  describe '#run' do
    let(:suggestions_store_response) { '' }
    let(:page) do
      create(:page, csv_source_url: 'http://example.com/export.csv')
    end

    before do
      stub_request(:get, 'http://example.com/export.csv')
        .to_return(status: 200, body: suggestions_store_response, headers: {})
    end

    context 'CSV file with transaction_id' do
      let(:suggestions_store_response) do
        [
          %w[
            transaction_id person_name
            electoral_district_name electoral_district_item
            fb_identifier
          ],
          %w[489434391472318 Alice Ambridge Q1234 10987654321],
          %w[1656343594481923 Bob Bambridge Q4321 10987654322]
        ].map(&:to_csv).join
      end

      before do
        stub_id_mapping_store(scheme_id: '7', identifier: '10987654322')
      end

      let!(:existing_statement) do
        create(:statement, transaction_id: '489434391472318',
                           person_name: 'Arthur', page: page)
      end

      it 'creates a missing statement' do
        load_statements = LoadStatements.new(page.title)
        expect { load_statements.run }.to change(Statement, :count).by(1)
        last_statement = Statement.last
        expect(last_statement.transaction_id).to eq('1656343594481923')
        expect(last_statement.person_name).to eq('Bob')
        expect(last_statement.electoral_district_name).to eq('Bambridge')
        expect(last_statement.electoral_district_item).to eq('Q4321')
        expect(last_statement.fb_identifier).to eq('10987654322')
      end

      it 'updates existing statements' do
        load_statements = LoadStatements.new(page.title)
        load_statements.run
        existing_statement.reload
        expect(existing_statement.transaction_id).to eq('489434391472318')
        expect(existing_statement.person_name).to eq('Alice')
        expect(existing_statement.electoral_district_name).to eq('Ambridge')
        expect(existing_statement.electoral_district_item).to eq('Q1234')
        expect(existing_statement.fb_identifier).to eq('10987654321')
      end
    end

    context 'CSV file not from suggestions-store' do
      let(:suggestions_store_response) do
        [
          %w[
            person_name person_item
            electoral_district_name electoral_district_item
          ],
          %w[Alice Q987 Ambridge Q1234],
          %w[Bob Q876 Bambridge Q4321]
        ].map(&:to_csv).join
      end

      let!(:existing_statement) do
        create(:statement,
               transaction_id: 'md5:d693e9beb0d9af365bb267982a479980',
               person_name: 'Arthur', page: page)
      end

      it 'creates a missing statement' do
        load_statements = LoadStatements.new(page.title)
        expect { load_statements.run }.to change(Statement, :count).by(1)
        last_statement = Statement.last
        expect(last_statement.transaction_id).to(
          eq 'md5:9a72129f7da4bf1d61e8e508cc5ef485'
        )
        expect(last_statement.person_name).to eq('Bob')
        expect(last_statement.person_item).to eq('Q876')
        expect(last_statement.electoral_district_name).to eq('Bambridge')
        expect(last_statement.electoral_district_item).to eq('Q4321')
      end

      it 'updates existing statements' do
        load_statements = LoadStatements.new(page.title)
        load_statements.run
        existing_statement.reload
        expect(existing_statement.transaction_id).to(
          eq 'md5:d693e9beb0d9af365bb267982a479980'
        )
        expect(existing_statement.person_name).to eq('Alice')
        expect(existing_statement.person_item).to eq('Q987')
        expect(existing_statement.electoral_district_name).to eq('Ambridge')
        expect(existing_statement.electoral_district_item).to eq('Q1234')
      end
    end
  end
end

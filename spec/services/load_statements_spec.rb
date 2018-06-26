require 'rails_helper'

RSpec.describe LoadStatements do
  context '#run' do
    before do
      suggestions_store_response = [
        %w[transaction_id person_name electoral_district_name electoral_district_item fb_identifier],
        %w[489434391472318 Alice Ambridge Q1234 10987654321],
        %w[1656343594481923 Bob Bambridge Q4321 10987654322],
      ].map(&:to_csv).join

      scheme_data = {
        'results' => [
          {
            'id' => 1,
            'name' => 'wikidata-persons'
          },
          {
            'id' => 2,
            'name' => 'wikidata-memberships'
          },
          {
            'id' => 3,
            'name' => 'wikidata-organizations'
          },
          {
            'id' => 4,
            'name' => 'ms-uuid-persons'
          },
          {
            'id' => 5,
            'name' => 'ms-uuid-memberships'
          },
          {
            'id' => 6,
            'name' => 'ms-uuid-organizations'
          },
          {
            'id' => 7,
            'name' => 'facebook-persons'
          }
        ]
      }
      id_mapping_store_base_url = ENV.fetch(
        'ID_MAPPING_STORE_BASE_URL', 'https://id-mapping-store.mysociety.org'
      )

      stub_request(:get, "#{id_mapping_store_base_url}/scheme")
        .to_return(status: 200, body: JSON.pretty_generate(scheme_data))
      stub_request(:get, "#{id_mapping_store_base_url}/identifier/7/10987654322")
        .to_return(status: 404, body: '')

      stub_request(:get, 'http://example.com/export.csv')
        .to_return(status: 200, body: suggestions_store_response, headers: {})
      @page = create(:page, csv_source_url: 'http://example.com/export.csv')
      @existing_statement = create(:statement, transaction_id: '489434391472318', person_name: 'Arthur', page: @page)
    end

    it 'creates a missing statement' do
      load_statements = LoadStatements.new(@page.title)
      expect { load_statements.run }.to change(Statement, :count).by(1)
      last_statement = Statement.last
      expect(last_statement.transaction_id).to eq('1656343594481923')
      expect(last_statement.person_name).to eq('Bob')
      expect(last_statement.electoral_district_name).to eq('Bambridge')
      expect(last_statement.electoral_district_item).to eq('Q4321')
      expect(last_statement.fb_identifier).to eq('10987654322')
    end

    it 'updates existing statements' do
      load_statements = LoadStatements.new(@page.title)
      load_statements.run
      @existing_statement.reload
      expect(@existing_statement.transaction_id).to eq('489434391472318')
      expect(@existing_statement.person_name).to eq('Alice')
      expect(@existing_statement.electoral_district_name).to eq('Ambridge')
      expect(@existing_statement.electoral_district_item).to eq('Q1234')
      expect(@existing_statement.fb_identifier).to eq('10987654321')
    end
  end
end

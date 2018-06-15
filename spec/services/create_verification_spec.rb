# frozen_string_literal: true

require 'json'
require 'rails_helper'

RSpec.describe CreateVerification, type: :service do
  let(:statement_params) do
    {
      person_name: 'Alice',
      electoral_district_name: 'Foo',
      electoral_district_item: 'Q123',
      fb_identifier: '444333'
    }
  end
  let(:statement) { create(:statement, statement_params) }

  before do
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
    stub_request(:get, "#{id_mapping_store_base_url}/identifier/7/444333")
      .to_return(status: 404, body: '')
  end

  context 'with valid params' do
    subject do
      CreateVerification.new(
        statement: statement,
        params: {
          user: 'foo', status: 'true', new_name: 'baz'
        }
      )
    end

    before { allow(UpdateStatementVerification).to receive(:run) }

    it 'creates a verification' do
      expect { subject.run }.to change { statement.verifications.count }.by(1)
    end

    it 'updates the statement with new_name, if relevant' do
      subject.run
      expect(statement.person_name).to eq('baz')
    end

    it 'adds verification to duplicate statements' do
      statement2 = create(
        :statement,
        statement_params.merge(transaction_id: '456')
      )
      expect { subject.run }.to change { statement2.verifications.count }.by(1)
    end
  end
end

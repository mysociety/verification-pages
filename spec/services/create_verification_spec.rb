# frozen_string_literal: true

require 'json'
require 'rails_helper'

RSpec.describe CreateVerification, type: :service do
  include_context 'id-mapping-store default setup'
  let(:page) { create(:page) }
  let(:statement_params) do
    {
      person_name:             'Alice',
      electoral_district_name: 'Foo',
      electoral_district_item: 'Q123',
      fb_identifier:           '444333',
      page:                    page,
    }
  end
  let(:statement) { create(:statement, statement_params) }

  before do
    stub_id_mapping_store(scheme_id: '7', identifier: '444333')
  end

  context 'with valid params' do
    subject do
      CreateVerification.new(
        statement: statement,
        params:    {
          user: 'foo', status: 'true', new_name: 'baz',
          reference_url: 'https://example.org/members/',
        }
      )
    end

    before { allow(UpdateStatementVerification).to receive(:run) }

    it 'creates a verification' do
      expect { subject.run }.to change { statement.verifications.count }.by(1)
    end

    it 'updates the statement with new_name, if relevant' do
      expect(statement.person_name).to_not eq('baz')
      subject.run
      expect { statement.reload }.to change(statement, :person_name).to('baz')
    end

    it 'updates the statement duplicate with new_name, if relevant' do
      statement2 = create(
        :statement,
        statement_params.merge(transaction_id: '456', page: statement.page)
      )
      expect(statement2.person_name).to_not eq('baz')
      subject.run
      expect { statement2.reload }.to change(statement2, :person_name).to('baz')
    end

    it 'adds verification to duplicate statements' do
      statement2 = create(
        :statement,
        statement_params.merge(transaction_id: '456', page: statement.page)
      )
      expect { subject.run }.to change { statement2.verifications.count }.by(1)
    end

    context 'page.reference_url' do
      let(:page) { create(:page, reference_url: '') }

      it 'is set if blank' do
        subject.run
        expect(page.reference_url).to eq('https://example.org/members/')
      end

      it 'is left untouched if not blank' do
        page.update(reference_url: 'http://example.com')
        subject.run
        expect(page.reference_url).to eq('http://example.com')
      end
    end
  end
end

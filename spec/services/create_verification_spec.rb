# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateVerification, type: :service do
  let(:statement_params) { { person_name: 'Alice', electoral_district_name: 'Foo', electoral_district_item: 'Q123', fb_identifier: '444333' } }
  let(:statement) { create(:statement, statement_params) }

  context 'with valid params' do
    subject { CreateVerification.new(statement: statement, params: { user: 'foo', status: 'true', new_name: 'baz' }) }

    before { allow(UpdateStatementVerification).to receive(:run) }

    it 'creates a verification' do
      expect { subject.run }.to change { statement.verifications.count }.by(1)
    end

    it 'updates the statement with new_name, if relevant' do
      subject.run
      expect(statement.person_name).to eq('baz')
    end

    it 'adds verification to duplicate statements' do
      statement2 = create(:statement, statement_params.merge(transaction_id: '456'))
      expect { subject.run }.to change { statement2.verifications.count }.by(1)
    end
  end
end
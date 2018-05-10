# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateVerification, type: :service do
  let(:statement) { create(:statement) }

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
  end
end

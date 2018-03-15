# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Verification, type: :model do
  let(:verification) { Verification.new }

  describe 'associations' do
    it 'belong to statement' do
      expect(verification.build_statement).to be_a(Statement)
    end
  end

  describe 'after commit callback' do
    it 'sends suggestion to suggestions store' do
      expect(UpdateStatementVerification).to receive(:run)
        .with(verification).once

      verification.create_statement!(
        transaction_id: '123',
        parliamentary_term_item: 'Q1'
      )
      verification.user = 'Bilbo'
      verification.save! # create

      expect(UpdateStatementVerification).to receive(:run)
        .with(verification).once

      verification.user = 'Frodo'
      verification.save! # update
    end
  end
end

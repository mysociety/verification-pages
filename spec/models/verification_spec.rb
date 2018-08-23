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
    context 'the page is from suggestions-store' do
      it 'sends verification to suggestions-store' do
        expect(UpdateStatementVerification).to receive(:run)
          .with(verification).once

        page = build(
          :page,
          csv_source_url: "#{ENV.fetch('SUGGESTIONS_STORE_URL')}/export/blah.csv"
        )
        verification.statement = build(:statement, page: page)
        verification.user = 'Bilbo'
        verification.reference_url = 'https://example.org/members/'
        verification.save! # create

        expect(UpdateStatementVerification).to receive(:run)
          .with(verification).once

        verification.user = 'Frodo'
        verification.save! # update
      end
    end

    context 'the page is not from suggestions-store' do
      it 'should not send verification to suggestions-store' do
        expect(UpdateStatementVerification).to_not receive(:run)

        verification.statement = build(:statement)
        verification.user = 'Bilbo'
        verification.reference_url = 'https://example.org/members/'
        verification.save! # create

        expect(UpdateStatementVerification).to_not receive(:run)

        verification.user = 'Frodo'
        verification.save! # update
      end
    end
  end

  describe 'validations' do
    let(:verification) { Verification.new }

    it 'requires reference_url' do
      verification.valid?
      expect(verification.errors).to include(:reference_url)
    end
  end
end

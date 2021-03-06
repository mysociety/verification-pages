# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateStatementVerification, type: :service do
  let(:new_name) { nil }
  let(:status) { true }
  let(:statement) { double(:statement, transaction_id: '123') }
  let(:verification) do
    double(:verification, statement: statement, status?: status, new_name: new_name)
  end

  let(:updater) { UpdateStatementVerification.new(verification) }

  describe 'initialisation' do
    it 'assigns instance variables' do
      expect(updater.transaction_id).to eq '123'
      expect(updater.verification).to eq verification
    end
  end

  describe 'running update' do
    before do
      stub_const('SuggestionsStore::Request::URL', 'http://example.com/')
    end

    context 'verified' do
      let(:status) { true }

      it 'posts correct to the suggestions store' do
        expect(RestClient).to receive(:post)
          .with('http://example.com/suggestions/123/verifications',
                status: 'correct')
        updater.run
      end
    end

    context 'unverified' do
      let(:status) { false }

      it 'posts correct to the suggestions store' do
        expect(RestClient).to receive(:post)
          .with('http://example.com/suggestions/123/verifications',
                status: 'incorrect')
        updater.run
      end
    end

    context 'name has been corrected' do
      let(:status) { true }
      let(:new_name) { 'Joseph Bloggs' }

      it 'posts corrected to the suggestions store' do
        expect(RestClient).to receive(:post)
          .with('http://example.com/suggestions/123/verifications',
                status: 'corrected')
        updater.run
      end
    end

    context 'when suggestions store errors' do
      before do
        allow(RestClient).to receive(:post).and_raise(RestClient::Exception)
      end

      it 're-raises error' do
        expect { updater.run }.to raise_error(
          'Suggestion store failed: RestClient::Exception'
        )
      end
    end
  end
end

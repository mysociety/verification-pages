# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Page::TransactionID, type: :model do
  let(:page) { build(:page) }

  describe '#generate_transaction_id' do
    subject { page.generate_transaction_id(data) }

    let(:data) { { foo: 'foo', bar: 'bar' } }

    context 'with hash_epoch = nil' do
      before { page.hash_epoch = nil }

      it 'should raise unknown hash epoch error' do
        expect { subject }.to raise_error 'Page::TransactionID::UnknownHashEpochError'
      end
    end

    context 'with hash_epoch = 1' do
      before { page.hash_epoch = 1 }

      it 'should merge the country code then MD5 stored hash data string' do
        data_string = 'bar:bar;country:ca;foo:foo'
        expect(Digest::MD5).to receive(:hexdigest).with(data_string) { 'abc' }
        is_expected.to eq 'md5:abc'
      end
    end
  end
end

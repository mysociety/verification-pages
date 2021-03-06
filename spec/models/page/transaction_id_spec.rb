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

    context 'with hash_epoch = 2' do
      before { page.hash_epoch = 2 }

      it 'should merge the country code and page ID then MD5 stored hash data string' do
        page.id = 1
        data_string = 'bar:bar;country:ca;foo:foo;page:1'
        expect(Digest::MD5).to receive(:hexdigest).with(data_string) { 'def' }
        is_expected.to eq 'md5:def'
      end
    end

    context 'with hash_epoch = 3' do
      before { page.hash_epoch = 3 }

      it 'should merge the country item and page ID then MD5 stored hash data string' do
        page.id = 1
        data_string = 'bar:bar;country:Q16;foo:foo;page:1'
        expect(Digest::MD5).to receive(:hexdigest).with(data_string) { 'ghi' }
        is_expected.to eq 'md5:ghi'
      end
    end
  end
end

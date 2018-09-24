# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Page::TransactionID, type: :model do
  let(:page) { build(:page) }

  describe '#generate_transaction_id' do
    subject { page.generate_transaction_id(data) }

    let(:data) { { foo: 'foo', bar: 'bar' } }

    it 'should merge the country code then MD5 stored hash data string' do
      data_string = 'bar:bar;country:ca;foo:foo'
      expect(Digest::MD5).to receive(:hexdigest).with(data_string) { 'abc' }
      is_expected.to eq 'md5:abc'
    end
  end
end

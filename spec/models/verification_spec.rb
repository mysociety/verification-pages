# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Verification, type: :model do
  let(:verification) { Verification.new }

  describe 'assoications' do
    it 'belong to statement' do
      expect(verification.build_statement).to be_a(Statement)
    end
  end
end

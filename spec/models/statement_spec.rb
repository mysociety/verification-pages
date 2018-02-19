# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Statement, type: :model do
  let(:statement) { Statement.new }

  describe 'assoications' do
    it 'has many verifications' do
      expect(statement.verifications.build).to be_a(Verification)
    end
  end
end

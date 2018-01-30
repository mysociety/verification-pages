# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Result, type: :model do
  let(:result) { Result.new }

  describe 'assoications' do
    it 'belong to statement' do
      expect(result.build_statement).to be_a(Statement)
    end
  end
end

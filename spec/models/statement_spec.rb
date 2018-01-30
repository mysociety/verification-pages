# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Statement, type: :model do
  let(:statement) { Statement.new }

  describe 'assoications' do
    it 'has many results' do
      expect(statement.results.build).to be_a(Result)
    end
  end
end

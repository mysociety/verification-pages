# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Page, type: :model do
  let(:page) { Page.new }

  describe 'validations' do
    before { page.valid? }

    it 'requires title' do
      expect(page.errors).to include(:title)
    end

    it 'requires position_held_item' do
      expect(page.errors).to include(:position_held_item)
    end

    it 'requires reference_url' do
      expect(page.errors).to include(:reference_url)
    end
  end
end

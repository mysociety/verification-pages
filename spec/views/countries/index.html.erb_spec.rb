# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'countries/index', type: :view do
  before(:each) do
    assign(:countries, [
             create(:country),
             create(:country),
           ])
  end

  it 'renders a list of countries' do
    render
    assert_select 'tr>td', text: 'Canada', count: 2
    assert_select 'tr>td', text: 'ca', count: 2
    assert_select 'tr>td', text: 'Q16', count: 2
  end
end

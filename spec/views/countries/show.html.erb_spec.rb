# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'countries/show', type: :view do
  before(:each) do
    @country = assign(:country, create(:country))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Canada/)
    expect(rendered).to match(/ca/)
    expect(rendered).to match(/Canadian politician/)
    expect(rendered).to match(/en/)
    expect(rendered).to match(/Q16/)
  end
end

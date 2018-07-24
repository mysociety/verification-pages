# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'countries/edit', type: :view do
  before(:each) do
    @country = assign(:country, create(:country))
  end

  it 'renders the edit country form' do
    render

    assert_select 'form[action=?][method=?]', country_path(@country), 'post' do
      assert_select 'input[name=?]', 'country[name]'

      assert_select 'input[name=?]', 'country[code]'

      assert_select 'input[name=?]', 'country[description_en]'

      assert_select 'input[name=?]', 'country[label_lang]'

      assert_select 'input[name=?]', 'country[wikidata_id]'
    end
  end
end

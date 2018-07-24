# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'countries/new', type: :view do
  before(:each) do
    assign(:country, build(:country))
  end

  it 'renders new country form' do
    render

    assert_select 'form[action=?][method=?]', countries_path, 'post' do
      assert_select 'input[name=?]', 'country[name]'

      assert_select 'input[name=?]', 'country[code]'

      assert_select 'input[name=?]', 'country[description_en]'

      assert_select 'input[name=?]', 'country[label_lang]'

      assert_select 'input[name=?]', 'country[wikidata_id]'
    end
  end
end

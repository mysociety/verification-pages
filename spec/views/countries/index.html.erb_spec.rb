require 'rails_helper'

RSpec.describe "countries/index", type: :view do
  before(:each) do
    assign(:countries, [
      Country.create!(
        :name => "Name",
        :code => "Code",
        :description_en => "Description En",
        :label_lang => "Label Lang",
        :wikidata_id => "Wikidata"
      ),
      Country.create!(
        :name => "Name",
        :code => "Code",
        :description_en => "Description En",
        :label_lang => "Label Lang",
        :wikidata_id => "Wikidata"
      )
    ])
  end

  it "renders a list of countries" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Code".to_s, :count => 2
    assert_select "tr>td", :text => "Description En".to_s, :count => 2
    assert_select "tr>td", :text => "Label Lang".to_s, :count => 2
    assert_select "tr>td", :text => "Wikidata".to_s, :count => 2
  end
end

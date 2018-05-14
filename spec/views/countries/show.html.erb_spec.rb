require 'rails_helper'

RSpec.describe "countries/show", type: :view do
  before(:each) do
    @country = assign(:country, Country.create!(
      :name => "Name",
      :code => "Code",
      :description_en => "Description En",
      :label_lang => "Label Lang",
      :wikidata_id => "Wikidata"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Code/)
    expect(rendered).to match(/Description En/)
    expect(rendered).to match(/Label Lang/)
    expect(rendered).to match(/Wikidata/)
  end
end

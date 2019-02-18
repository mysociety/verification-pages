# frozen_string_literal: true

RSpec.configure do |config|
  config.before do
    country_result = Struct.new(:country)
    allow(RetrieveCountry).to receive(:run).and_return(country_result.new('P16'))
    allow(RetrieveItems).to receive(:run).and_return({})
  end
end

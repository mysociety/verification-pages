# frozen_string_literal: true

RSpec.configure do |config|
  config.before do
    allow(RetrieveLabels).to receive(:run).and_return({})
  end
end

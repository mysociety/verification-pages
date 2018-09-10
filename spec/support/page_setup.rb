# frozen_string_literal: true

RSpec.configure do |config|
  config.before do
    allow(RetrievePageData).to receive(:run).and_return(nil)
  end
end

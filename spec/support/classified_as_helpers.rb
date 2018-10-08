# frozen_string_literal: true

RSpec.shared_examples 'classified as' do |current_state|
  %w[
    verifiable unverifiable reconcilable
    actionable manually_actionable done
    reverted removed
  ].each do |state|
    if state == current_state
      it "should be classified as #{state}" do
        expect(classifier.public_send(state)).to eq(statements)
      end
    else
      it "should not be classified as #{state}" do
        expect(classifier.public_send(state)).to be_empty
      end
    end
  end
end

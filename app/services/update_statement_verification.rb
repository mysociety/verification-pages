# frozen_string_literal: true

class UpdateStatementVerification < ServiceBase
  attr_reader :transaction_id, :verification

  def initialize(verification)
    @transaction_id = verification.statement.transaction_id
    @verification = verification
  end

  def run
    SuggestionsStore::Suggestion.new(transaction_id: transaction_id)
                                .verify!(status: status)
  end

  private

  def status
    return 'incorrect' unless verification.status?
    verification.new_name ? 'corrected' : 'correct'
  end
end

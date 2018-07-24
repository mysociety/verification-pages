# frozen_string_literal: true

class UpdateStatementVerification < ServiceBase
  attr_reader :transaction_id, :verification

  def initialize(verification)
    @transaction_id = verification.statement.transaction_id
    @verification = verification
  end

  def run
    uri = URI(ENV.fetch('SUGGESTIONS_STORE_URL'))
    uri.path = "/suggestions/#{transaction_id}/verifications"
    RestClient.post(uri.to_s, status: status)
  rescue RestClient::Exception => e
    raise "Suggestion store failed: #{e.message}"
  end

  private

  def status
    return 'incorrect' unless verification.status?
    verification.new_name ? 'corrected' : 'correct'
  end
end

# frozen_string_literal: true

# Controller to receive POST reconciliation requests from verification pages on
# Wikidata
class VerificationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    statement = Statement.find_by(transaction_id: params.fetch(:id))
    statement.create_verification!(verification_params)
  end

  private

  def verification_params
    params.permit(%i[user status])
  end
end

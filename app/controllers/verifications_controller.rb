# frozen_string_literal: true

# Controller to receive POST reconciliation requests from verification pages on
# Wikidata
class VerificationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    transaction_id = params.fetch(:id)
    statement = Statement.find_by(transaction_id: transaction_id)
    statement.create_verification!(verification_params)

    page = statement.page

    @classifier = StatementClassifier.new(page.title, transaction_id)

    respond_to do |format|
      format.json { render file: 'statements/show' }
    end
  end

  private

  def verification_params
    params.permit(%i[user status])
  end
end

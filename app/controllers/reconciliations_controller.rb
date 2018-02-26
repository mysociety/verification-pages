# frozen_string_literal: true

# Controller to receive POST reconciliation requests from verification tool on
# Wikidata
class ReconciliationsController < FrontendController
  def create
    statement = Statement.find_by!(transaction_id: params.fetch(:id))
    statement.reconciliations.create!(reconciliation_params)

    respond_with(statement)
  end

  private

  def reconciliation_params
    params.permit(%i[user item])
  end
end

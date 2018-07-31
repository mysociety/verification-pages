# frozen_string_literal: true

# Controller to receive POST reconciliation requests from verification tool on
# Wikidata
class ReconciliationsController < FrontendController
  def create
    params[:update_type] ||= 'single'
    statement = Statement.find_by!(transaction_id: params.fetch(:id))
    reconciliation = statement.reconciliations.create!(reconciliation_params)
    respond_with(statement, reconciliation.possibly_updated_statements)
  end

  private

  def reconciliation_params
    params.permit(%i[user item resource_type update_type])
  end
end

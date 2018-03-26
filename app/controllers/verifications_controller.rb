# frozen_string_literal: true

# Controller to receive POST verification requests from verification tool on
# Wikidata
class VerificationsController < FrontendController
  def create
    statement = Statement.find_by!(transaction_id: params.fetch(:id))
    statement.verifications.create!(verification_params)

    # If there was a correction to the name, save that on the
    # statement so it'll be used for reconciliation and actioning:
    statement.update_attributes(person_name: params[:new_name]) if params[:new_name]

    respond_with(statement)
  end

  private

  def verification_params
    params.permit(%i[user status new_name])
  end
end

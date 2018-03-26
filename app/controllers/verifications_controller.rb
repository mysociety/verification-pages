# frozen_string_literal: true

# Controller to receive POST verification requests from verification tool on
# Wikidata
class VerificationsController < FrontendController
  def create
    statement = Statement.find_by!(transaction_id: params.fetch(:id))
    statement.verifications.create!(verification_params)

    respond_with(statement)
  end

  private

  def verification_params
    params.permit(%i[user status new_name])
  end
end

# Service for creating a new verification
class CreateVerification < ServiceBase
  def initialize(statement:, params:)
    @statement = statement
    @params = params
  end

  def run
    statement.verifications.create!(params)

    # If there was a correction to the name, save that on the
    # statement so it'll be used for reconciliation and actioning:
    statement.update_attributes(person_name: params[:new_name]) if params[:new_name]
  end

  private

  attr_reader :statement, :params
end

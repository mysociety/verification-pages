# frozen_string_literal: true

# Service for creating a new verification
class CreateVerification < ServiceBase
  def initialize(statement:, params:)
    @statement = statement
    @params = params
  end

  def run
    statement.verifications.create!(params)

    # Only update the reference URL on a page if it's missing
    statement.page.update(reference_url: params[:reference_url]) if statement.page.reference_url.blank?

    # Find duplicate statements and update their verifications
    statement.duplicate_statements.each do |duplicate_statement|
      duplicate_statement.verifications.create!(params)
    end

    # If there was a correction to the name, save that on the
    # statement so it'll be used for reconciliation and actioning:
    statement.update(person_name: params[:new_name]) if params[:new_name]
  end

  private

  attr_reader :statement, :params, :reference_url
end

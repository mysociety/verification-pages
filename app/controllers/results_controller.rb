# frozen_string_literal: true

# Controller to receive POST requests from verification pages on Wikidata
class ResultsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    statement = Statement.find(params.fetch(:id))
    statement.update_result(result_params)
  end

  private

  def result_params
    params.permit(%i[object property qualifier_p2937 qualifier_p4100
                     qualifier_p768 statement subject user value])
  end
end

# frozen_string_literal: true

# Controller to receive POST verification requests from verification tool on
# Wikidata
class FrontendController < ApplicationController
  skip_before_action :verify_authenticity_token

  def respond_with(statement, statements = nil)
    page = statement.page
    statements ||= [statement]

    @classifier = StatementClassifier.new(
      page.title,
      statements.map(&:transaction_id)
    )

    respond_to do |format|
      format.json { render file: 'statements/index' }
    end
  end
end

# frozen_string_literal: true

# Controller to receive POST verification requests from verification tool on
# Wikidata
class FrontendController < ApplicationController
  skip_before_action :verify_authenticity_token

  def respond_with(statement, statements = nil)
    @bulk_update = statements && (statements.length > 1)
    page = statement.page
    statements ||= [statement]

    @classifier = classify_page(page, statements)

    respond_to do |format|
      format.json { render file: 'statements/index' }
    end
  end

  def classify_page(page, statements = [])
    StatementClassifier.new(
      page.title,
      transaction_ids: statements.map(&:transaction_id)
    )
  end
end

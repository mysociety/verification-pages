# frozen_string_literal: true

# Controller to receive POST verification requests from verification tool on
# Wikidata
class FrontendController < ApplicationController
  skip_before_action :verify_authenticity_token

  def respond_with(statement)
    page = statement.page
    @classifier = StatementClassifier.new(page.title, statement.transaction_id)

    respond_to do |format|
      format.json { render file: 'statements/index' }
    end
  end
end

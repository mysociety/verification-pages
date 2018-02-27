class StatementsController < ApplicationController
  def index
    page = Page.find_by!(title: params.require(:title))
    @classifier = StatementClassifier.new(page.title)

    respond_to do |format|
      format.json { render }
    end
  end
end

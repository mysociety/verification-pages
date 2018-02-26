class StatementsController < ApplicationController
  def show
    page = Page.find_by!(title: params[:id])
    @classifier = StatementClassifier.new(page.title)
    respond_to do |format|
      format.json { render }
    end
  end
end

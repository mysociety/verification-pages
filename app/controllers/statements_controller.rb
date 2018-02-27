class StatementsController < FrontendController
  def index
    page = Page.find_by!(title: params.require(:title))
    @classifier = StatementClassifier.new(page.title)

    respond_to do |format|
      format.json { render }
    end
  end

  def show
    statement = Statement.find_by!(transaction_id: params.fetch(:id))
    respond_with(statement)
  end
end

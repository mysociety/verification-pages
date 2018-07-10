# frozen_string_literal: true

class StatementsController < FrontendController
  def index
    page = Page.find_by!(title: params.require(:title))
    @classifier = StatementClassifier.new(page.title)

    respond_to do |format|
      format.json { render }
    end
  end

  def statistics
    @country_statements = StatementsStatistics.new.statistics
  end

  def show
    statement = Statement.find_by!(transaction_id: params.fetch(:id))

    case params[:force_type]
    when 'done'
      statement.record_actioned!
    when 'manually_actionable'
      statement.report_error!(params[:error_message])
    when 'actionable'
      statement.clear_error!
    end

    respond_with(statement)
  end
end

# frozen_string_literal: true

class StatementsController < FrontendController
  def index
    page = Page.find_by!(title: params.require(:title))
    @classifier = classify_page(page)

    respond_to do |format|
      format.json { render }
    end
  end

  def statistics
    @country_statements = StatementsStatistics.new.statistics
    @country_lookup = Page.select(:country_code, :country_name).distinct.each_with_object({}) do |p, memo|
      memo[p.country_code] ||= p.country_name
    end
    positions = @country_statements.values.map(&:first).flatten.map(&:position)
    @position_name_mapping = RetrieveItems.run(*positions)
  end

  def show
    statement = Statement.find_by!(transaction_id: params.fetch(:id))

    case params[:force_type]
    when 'done'
      statement.record_actioned!(PageClassifier::VERSION)
    when 'manually_actionable'
      statement.report_error!(params[:error_message])
    when 'actionable'
      statement.clear_error!
    end

    respond_with(statement)
  end
end

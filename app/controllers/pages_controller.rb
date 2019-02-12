# frozen_string_literal: true

# Controller to manage verification pages
class PagesController < ApplicationController
  include AdminAuthentication
  include ApplicationHelper

  before_action :set_page, only: %i[show edit update destroy load create_wikidata]
  skip_before_action :authenticate, if: -> { params[:action] == 'index' && params[:format] == 'json' }

  # GET /pages
  def index
    @pages = Page.includes(:country).all
  end

  # GET /pages/1
  def show
    @query = RetrievePositionData.new(@page.position_held_item).query
  end

  # GET /pages/new
  def new
    @page = Page.new(new_page_params)
  end

  # GET /pages/1/edit
  def edit; end

  # POST /pages
  def create
    @page = Page.new(page_params)

    if @page.save
      redirect_to @page, notice: 'Page was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /pages/1
  def update
    if @page.update(page_params)
      redirect_to @page, notice: 'Page was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /pages/1
  def destroy
    @page.destroy
    redirect_to pages_url, notice: 'Page was successfully destroyed.'
  end

  # POST /pages/1/load
  def load
    statements = LoadStatements.run(@page.title)
    redirect_to @page, notice: "#{statements.count} Statements loaded"
  end

  # POST /pages/1/create_wikidata
  def create_wikidata
    UpdateVerificationPage.run(@page.title)
    redirect_to @page, notice: 'Verification page now visible at: ' + url_to_wiki(@page.title)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_page
    @page = Page.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def page_params
    params.require(:page).permit(:title, :position_held_item,
                                 :parliamentary_term_item, :reference_url,
                                 :country_id, :country_item, :country_code,
                                 :csv_source_url, :executive_position,
                                 :reference_url_title, :reference_url_language,
                                 :archived, :new_item_description_en,
                                 :new_item_label_language)
  end

  def new_page_params
    params.permit(:title, :position_held_item, :csv_source_url, :country_id)
  end
end

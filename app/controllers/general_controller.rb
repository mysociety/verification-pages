# frozen_string_literal: true

class GeneralController < ApplicationController
  def index; end

  def frontend
    @page = Page.find_by(id: params[:id]) || Page.first
    render layout: false
  end
end

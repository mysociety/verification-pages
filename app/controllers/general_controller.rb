class GeneralController < ApplicationController
  def index; end

  def frontend
    render layout: false
  end
end

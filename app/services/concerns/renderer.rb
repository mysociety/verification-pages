# frozen_string_literal: true

# Provides render method to services
module Renderer
  extend ActiveSupport::Concern

  def render(template, **values)
    View.new(template.dirname).render file: template.basename, locals: values
  end

  # Subclass of ActionView for rendering helper methods
  class View < ActionView::Base
    include ApplicationHelper
    include Rails.application.routes.url_helpers
  end
end

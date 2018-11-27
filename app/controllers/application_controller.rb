# frozen_string_literal: true

class ApplicationController < ActionController::Base # :nodoc:
  protect_from_forgery with: :exception

  helper_method :authenticated?

  def authenticated?
    false
  end
end

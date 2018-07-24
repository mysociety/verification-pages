# frozen_string_literal: true

# Include this in a controller to protect it with basic auth.
#
# Set the ADMIN_USERNAME and ADMIN_PASSWORD environment variables to activate this module.
module AdminAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate
  end

  def authenticate
    return unless admin_password && admin_password
    authenticate_or_request_with_http_basic do |username, password|
      username == admin_username && password == admin_password
    end
  end

  def admin_username
    ENV['ADMIN_USERNAME']
  end

  def admin_password
    ENV['ADMIN_PASSWORD']
  end
end

# frozen_string_literal: true

Rails.application.routes.default_url_options = {
  host:     ENV['HOST_NAME'],
  protocol: ENV['FORCE_SSL'] ? 'https' : 'http',
}

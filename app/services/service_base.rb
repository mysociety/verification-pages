# frozen_string_literal: true

# Base service class
class ServiceBase
  def self.run(*args)
    new(*args).run
  end
end

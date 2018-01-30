# frozen_string_literal: true

# Statement for verification object
class Statement < ApplicationRecord
  has_many :results, dependent: :destroy

  def latest_result
    results.last
  end
end

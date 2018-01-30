# frozen_string_literal: true

# Statement for verification object
class Statement < ApplicationRecord
  has_many :results, dependent: :destroy

  def latest_result
    results.last
  end

  def result
    @result ||= latest_result || results.build
  end

  def update_verification(params)
    value = map_value(params[:value])

    result.status = value ? :yes : :no
    result.user = params[:user]

    result.save!
  end

  def update_result(params)
    value = map_value(params[:value])

    result.status = value ? :yes : :no
    result.user = params[:user]

    if value
      self.person_item = params[:subject]
      self.statement_uuid = params[:statement]
      self.parliamentary_group_item = params[:qualifier_p4100]
      self.electoral_district_item = params[:qualifier_p768]
      self.parliamentary_term_item = params[:qualifier_p2937]
    end

    save!
  end

  def map_value(value)
    value == 'true'
  end
end

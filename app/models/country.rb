# frozen_string_literal: true

class Country < ApplicationRecord
  has_many :pages

  validates :name, presence: true
  validates :code, presence: true, length: { in: 2..3 }
  validates :wikidata_id, presence: true, format: { with: /\AQ\d+\z/, message: 'must be a valid Wikidata item identifier, e.g. Q42' }
end

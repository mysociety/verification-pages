# frozen_string_literal: true

class Country < ApplicationRecord
  validates :name, presence: true
  validates :code, presence: true, length: { in: 2..3 }
  validates :description_en, presence: true
  validates :label_lang, presence: true, inclusion: { in: WikimediaLanguageCodes.all }
  validates :wikidata_id, presence: true, format: { with: /\AQ\d+\z/, message: 'must be a valid Wikidata item identifier, e.g. Q42' }
end

# frozen_string_literal: true

class IDMappingStore
  def initialize(wikidata_id: nil, facebook_id: nil)
    @wikidata_id = wikidata_id
    @facebook_id = facebook_id
  end

  def create_equivalence_claim(comment)
    # return if we don't have either Wikidata or FB IDs
    return unless @wikidata_id && @facebook_id
    # create equivalence claim between IDs
    wd[@wikidata_id].set(fb[@facebook_id], comment: comment)
  end

  def wikidata_id
    # get Wikidata identifier
    @wikidata_id ||= fb[@facebook_id].get(wd) if @facebook_id
  end

  def facebook_id
    # get Facebook identifier
    @facebook_id ||= wd[@wikidata_id].get(fb) if @wikidata_id
  end

  private

  def self.wd
    @wd ||= IDMapper.scheme('wikidata-persons')
  end

  def self.fb
    @fb ||= IDMapper.scheme('facebook-persons')
  end

  def wd
    self.class.wd
  end

  def fb
    self.class.fb
  end
end

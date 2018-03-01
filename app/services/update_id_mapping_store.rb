class UpdateIDMappingStore < ServiceBase
  attr_reader :wikidata_id, :facebook_id, :name

  def initialize(reconciliation)
    @wikidata_id = reconciliation.item
    @facebook_id = reconciliation.statement.fb_identifier
    @name = reconciliation.statement.person_name
  end

  def self.mapper
    @mapper ||= IDMapper.new
  end

  def mapper
    self.class.mapper
  end

  def run
    # return if we don't have either Wikidata or FB IDs
    return unless wikidata_id && facebook_id
    # look for existing FB IDs
    fb_id = mapper.fb_id_for(wikidata_id)
    # return early if the match, nothing left to do
    return if fb_id == facebook_id
    # deprecate old FB ID
    mapper.new_fb_id_for(fb_id, wikidata_id, deprecated: true) if fb_id
    # add new FB ID
    mapper.new_fb_id_for(facebook_id, wikidata_id, "Added FB ID for #{name}")
  end
end

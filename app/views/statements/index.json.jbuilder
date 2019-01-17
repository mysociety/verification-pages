# frozen_string_literal: true

json.statements @classifier.statements do |statement|
  json.call(
    statement,
    :type,
    :transaction_id,
    :person_item,
    :person_revision,
    :statement_uuid,
    :parliamentary_group_item,
    :electoral_district_item,
    :parliamentary_term_item,
    :created_at,
    :updated_at,
    :person_name,
    :parliamentary_group_name,
    :electoral_district_name,
    :parliamentary_term_name,
    :problems,
    :problem_reported?
  )

  if statement.latest_verification
    json.verified_on "+#{statement.verified_on.iso8601}T00:00:00Z"
    json.verification_status statement.latest_verification.status
    json.reference_url statement.latest_verification.reference_url
  else
    json.verified_on nil
    json.verification_status nil
  end

  if statement.position_start
    json.position_start "+#{statement.position_start.iso8601}T00:00:00Z"
  else
    json.position_start nil
  end

  if statement.position_end
    json.position_end "+#{statement.position_end.iso8601}T00:00:00Z"
  else
    json.position_end nil
  end

  json.bulk_update @bulk_update
end

json.page @classifier.page, :reference_url, :position_held_item, :executive_position, :reference_url_title, :reference_url_language, :new_item_description_en

json.country @classifier.page.country, :label_lang

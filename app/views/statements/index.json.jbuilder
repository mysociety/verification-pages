json.statements @classifier.to_a do |statement|
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
    :problems,
    :reconciliations
  )

  if statement.verified_on
    json.verified_on "+#{statement.verified_on.iso8601}"
  else
    json.verified_on nil
  end
end

json.page @classifier.page, :reference_url, :position_held_item

json.country @classifier.page.country

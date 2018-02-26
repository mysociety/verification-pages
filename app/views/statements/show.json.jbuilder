json.statements @classifier.to_a,
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
  :electoral_district_name

json.page @classifier.page, :reference_url

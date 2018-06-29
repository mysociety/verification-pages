desc 'Add resource_type to existing reconciliations'
task add_resource_type_to_reconciliations: :environment do
  Reconciliation.where(resource_type: nil).find_each do |reconciliation|
    reconciliation.resource_type ||= 'person'
    reconciliation.save!
  end
end

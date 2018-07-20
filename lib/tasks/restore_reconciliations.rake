desc 'Restore reconciled item IDs on statements from the reconciliations table'
task restore_reconciliations: :environment do
  # Touching each reconciliation should trigger the `after_commit`
  # callback, which updates the statement to set the reconciled item
  # value. We want to do this in the order they were created -
  # fortunately, find_each orders on the primary key, so this should
  # be the case.
  Reconciliation.find_each do |reconciliation|
    reconciliation.touch
  end
end

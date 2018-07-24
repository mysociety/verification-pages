# frozen_string_literal: true

task verify_historic_duplicates: :environment do
  Statement.original.each do |statement|
    latest_verification = statement.latest_verification
    next if latest_verification.blank?
    statement.duplicate_statements.each do |duplicate_statement|
      duplicate_statement.verifications.find_or_create_by!(
        user:   latest_verification.user,
        status: latest_verification.status
      )
    end
  end
end

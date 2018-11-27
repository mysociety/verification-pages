# frozen_string_literal: true

namespace :data_check do
  desc 'Update Wikidata page with the latest data check report'
  task update: :environment do
    page_title = "User:#{ENV.fetch('WIKIDATA_USERNAME')}/data_check"

    s = StringIO.new
    oldstdout = $stdout
    $stdout = s
    Rake.application['data_check:report'].invoke
    $stdout = oldstdout
    page_content = s.string

    UpdateWikidataPage.run(page_title, page_content)
  end

  desc 'Detect incorrect data in Wikidata'
  task report: :environment do
    Page.distinct.pluck(:position_held_item).each do |position_held|
      log_lines = []

      log_lines << "== {{Q|#{position_held.sub(/^Q/, '')}}} ==\n"

      Page.where(position_held_item: position_held).each do |page|
        log_lines << "[[#{page.title}]]\n"
      end

      query = RetrieveAllPositionData.new(position_held)
      total_errors = query.map do |(person, results)|
        # find statements which match the position held we're interested in
        matching = results.select { |r| r.position_held == position_held }

        issues = matching.each_with_object({}) do |result, h|
          # include all the persons other statements for comparision, even those
          # for other position held
          other = results - [result]

          # find duplicates based on term & district
          duplicates = find_duplicates(result, other)
          next if duplicates.empty?

          # check for any bad data
          errors = (
            check_duplicates(result, duplicates) +
            check_dates(result, duplicates)
          ).compact.flatten

          h[result.position] = errors unless errors.empty?
        end

        next if issues.empty?

        log_lines << "* {{Q|#{person.sub(/^Q/, '')}}} has #{matching.count} matching P39s"
        issues.each do |(position, (error, duplicate))|
          log_lines << "*# #{error} (#{position}, #{duplicate.position})"
        end

        issues.count
      end

      total_errors = total_errors.compact.sum
      if ENV['DATA_CHECK_DEBUG'] || !total_errors.zero?
        log_lines.each { |line| puts line }
        puts "\n#{total_errors} errors detected\n\n"
      end
    end
  end

  def find_duplicates(result, other_results)
    other_results.select do |other|
      other.term == result.term && other.district == result.district
    end
  end

  # find statements that match statements for the parent position held item
  # See: https://github.com/mysociety/verification-pages/issues/314
  def check_duplicates(result, duplicates)
    duplicates.map do |duplicate|
      conflict = duplicate.position_held == result.parent_position_held
      ['Possible clash with parent position held', duplicate] if conflict
    end
  end

  # find statements that match statements which started between terms
  # See: https://github.com/mysociety/verification-pages/issues/236
  def check_dates(result, duplicates)
    duplicates.select! { |duplicate| duplicate.position_held == result.position_held }
    return [] if duplicates.empty? || result.previous_term_end.blank?

    duplicates.map do |duplicate|
      next if result.position_start.blank?
      conflict = (duplicate.previous_term_end && duplicate.previous_term_end < result.position_start) &&
                 (duplicate.term_start && result.position_start < duplicate.term_start)
      ['Conflicting dates', duplicate] if conflict
    end
  end
end

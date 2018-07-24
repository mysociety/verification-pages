# frozen_string_literal: true

class PositionStatistics
  attr_reader :position

  def initialize(position:, statements:, existing_positions:)
    @position = position
    @statements = statements
    @existing_positions = existing_positions
  end

  def pages
    @pages ||= existing_positions.fetch(position, Set.new).sort
  end

  def unchecked
    statements.count { |s| s['verification_status'].nil? }
  end

  def correct
    statements.count { |s| s['verification_status'] == 'correct' }
  end

  def incorrect
    statements.count { |s| s['verification_status'] == 'incorrect' }
  end

  private

  attr_reader :statements, :existing_positions
end

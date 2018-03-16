# frozen_string_literal: true

require 'csv'
require 'open-uri'

csv_url = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vTkTgZvOPT71Xv7hGyDktIOqPEKU2rrWZcf1WsKEZXwe23zWCZYQYIHgdG_Gm-ljp8emCB1dsqzSO9T/pub?output=csv'
raw_data = open(csv_url).read

out = ['# frozen_string_literal: true']

CSV.parse(raw_data, headers: true).each do |row|
  title = row['page_title']
  url = row['reference_url']
  position = row['position_held_item']
  term = row['parliamentary_term_item']

  create_with = ["title: '#{title}'"]
  create_with << "reference_url: '#{url}'" unless url.nil?
  create_with << "require_parliamentary_group: true"

  attrs = ["position_held_item: '#{position}'"]
  attrs << "parliamentary_term_item: '#{term}'" unless term.nil?

  out << <<~RB
    Page.create_with(
      #{create_with.join(",\n  ")}
    ).find_or_create_by(
      #{attrs.join(",\n  ")}
    )
  RB
end

puts out.join("\n")

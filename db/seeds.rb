# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database
# with its default values. The data can then be loaded with the rails db:seed
# command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' },
#     { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Page.create_with(
  title: 'User:Graemebp/verification',
  reference_url: 'https://www.parliament.uk/mps-lords-and-offices/mps/',
  require_parliamentary_group: true
).find_or_create_by(
  position_held_item: 'Q30524710', # Member of 57th UK Parl
  parliamentary_term_item: 'Q29974940' # 57th UK Parliament
)

Statement.create_with(
  parliamentary_group_item: 'Q6467393',
  parliamentary_group_name: 'Labour Co-operative',
  electoral_district_item: 'Q3238926',
  electoral_district_name: 'Cardiff South & Penarth',
  parliamentary_term_item: 'Q29974940' # 57th UK Parliament
).find_or_create_by(
  person_item: 'Q7609085',
  person_name: 'Stephen Doughty'
)

Page.create_with(
  title: 'User:Graemebp/verification/ca',
  reference_url: 'https://www.ourcommons.ca/Parliamentarians/en/members?view=ListAll',
  require_parliamentary_group: true
).find_or_create_by(
  position_held_item: 'Q15964890', # member of the House of Commons of Canada
  parliamentary_term_item: 'Q21157957' # 42nd Canadian Parliament
)

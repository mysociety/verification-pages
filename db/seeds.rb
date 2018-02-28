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
  person_item: 'Q7609085',
  person_name: 'Stephen Doughty',
  parliamentary_group_item: 'Q6467393',
  parliamentary_group_name: 'Labour Co-operative',
  electoral_district_item: 'Q3238926',
  electoral_district_name: 'Cardiff South & Penarth',
  parliamentary_term_item: 'Q29974940' # 57th UK Parliament
).find_or_create_by!(
  transaction_id: '123'
)

Page.create_with(
  title: 'User:Graemebp/verification/ca',
  reference_url: 'https://www.ourcommons.ca/Parliamentarians/en/members?view=ListAll',
  require_parliamentary_group: true
).find_or_create_by!(
  position_held_item: 'Q15964890', # member of the House of Commons of Canada
  parliamentary_term_item: 'Q21157957' # 42nd Canadian Parliament
)

Page.create_with(
  title: 'User:Graemebp/verification/ca/alberta',
  reference_url: 'https://www.assembly.ab.ca/net/index.aspx?p=mla_report&memPhoto=True&alphaboth=True&alphaindex=True&build=y&caucus=All&conoffice=True&legoffice=True&mememail=False',
  require_parliamentary_group: true
).find_or_create_by!(
  position_held_item: 'Q15964815', # member of Alberta Legislative Assembly
  parliamentary_term_item: 'Q19876139' # 29th Alberta Legislatur
)

Page.create_with(
  title: 'User:Graemebp/verification/ca/manitoba',
  reference_url: 'https://www.gov.mb.ca/legislature/members/mla_list_alphabetical.html',
  require_parliamentary_group: true
).find_or_create_by!(
  position_held_item: 'Q19007867', # member of the Legislative Assembly of Manitoba
  parliamentary_term_item: 'Q24191581' # 41st Manitoba Legislature
)

Page.create_with(
  title: 'User:Graemebp/verification/ca/quebec',
  reference_url: 'http://www.assnat.qc.ca/en/deputes/index.html#listeDeputes',
  require_parliamentary_group: true
).find_or_create_by!(
  position_held_item: 'Q3305338', # Member of the National Assembly of Quebec
  parliamentary_term_item: 'Q16246364' # 41st Quebec Legislature
)

Page.create_with(
  title: 'User:Graemebp/verification/ca/newfoundland',
  reference_url: 'http://www.assembly.nl.ca/Members/members.aspx',
  require_parliamentary_group: true
).find_or_create_by(
  position_held_item: 'Q19403853', # Member of the Newfoundland and Labrador House of Assembly
  parliamentary_term_item: 'Q25000468' # 48th General Assembly of Newfoundland and Labrador
)

Page.create_with(
  title: 'User:Graemebp/verification/ca/saskatchewan',
  reference_url: 'http://www.legassembly.sk.ca/mlas/',
  require_parliamentary_group: true
).find_or_create_by!(
  position_held_item: 'Q18675661', # Member of the Legislative Assembly of Saskatchewan
  parliamentary_term_item: 'Q49224615' # 28th Legislative Assembly of Saskatchewan
)

Page.create_with(
  title: 'User:Graemebp/verification/ca/princeedwardisland',
  reference_url: 'http://www.assembly.pe.ca/current-members',
  require_parliamentary_group: true
).find_or_create_by!(
  position_held_item: 'Q21010685', # Member of the Legislative Assembly of Prince Edward Island
  parliamentary_term_item: 'Q20683815' # 65th General Assembly of Prince Edward Island
)

Page.create_with(
  title: 'User:Graemebp/verification/ca/britishcolumbia',
  reference_url: 'https://www.leg.bc.ca/Pages/BCLASS-Search-Constituency.aspx',
  require_parliamentary_group: true
).find_or_create_by!(
  position_held_item: 'Q19004821', # Member of the Legislative Assembly of British Columbia
  parliamentary_term_item: 'Q29561388' # 41st Parliament of British Columbia
)

Page.create_with(
  title: 'User:Graemebp/verification/ca/novascotia',
  reference_url: 'https://nslegislature.ca/members/profiles',
  require_parliamentary_group: true
).find_or_create_by!(
  position_held_item: 'Q18239264', # member of the Nova Scotia House of Assembly
  parliamentary_term_item: 'Q30682157' # 63rd General Assembly of Nova Scotia
)

Page.create_with(
  title: 'User:Graemebp/verification/ca/northwestterrirories',
  reference_url: 'http://www.assembly.gov.nt.ca/members',
  require_parliamentary_group: true
).find_or_create_by!(
  position_held_item: 'Q45308871', # Member of the Legislative Assembly of the Northwest Territories
  parliamentary_term_item: 'Q48698545' # 18th Northwest Territories Legislative Assembly
)

Page.create_with(
  title: 'User:Graemebp/verification/ca/ontario',
  reference_url: 'http://www.ontla.on.ca/web/members/members_current.do?locale=en',
  require_parliamentary_group: true
).find_or_create_by!(
  position_held_item: 'Q3305347', # Member of Ontario Provincial Parliament
  parliamentary_term_item: 'Q1809086' # Legislative Assembly of Ontario
)

Page.create_with(
  title: 'User:Graemebp/verification/ca/newbrunswick',
  reference_url: 'http://www.gnb.ca/gnb/Pub/MLAReport1.asp',
  require_parliamentary_group: true
).find_or_create_by!(
  position_held_item: 'Q18984329', # member of the Legislative Assembly of New Brunswick
  parliamentary_term_item: 'Q18220962' # 58th New Brunswick Legislature
)

Page.create_with(
  title: 'User:Graemebp/verification/ca/nunavut',
  reference_url: 'http://www.assembly.nu.ca/members/mla',
  require_parliamentary_group: true
).find_or_create_by!(
  position_held_item: 'Q45308607', # Member of the Legislative Assembly of Nunavut
  parliamentary_term_item: 'Q47484115' # 5th Legislative Assembly of Nunavut
)

Page.create_with(
  title: 'User:Graemebp/verification/ca/yukon',
  reference_url: 'http://www.legassembly.gov.yk.ca/members/index.html',
  require_parliamentary_group: true
).find_or_create_by!(
  position_held_item: 'Q18608478', # Member of the Yukon Legislative Assembly
  parliamentary_term_item: 'Q29561167' # 34th Yukon Legislative Assembly
)

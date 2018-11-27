# frozen_string_literal: true

module ApplicationHelper # :nodoc:
  def render_row(page, statement, options = {})
    render 'statement.mediawiki', row_options(page, statement).merge(options)
  end

  def row_options(page, statement)
    {
      id:                   statement.transaction_id,
      statement:            statement.statement_uuid,
      subject:              statement.person_item,
      subject_name:         statement.person_name,
      property:             'P39',
      object:               page.position_held_item,
      qualifier_p768:       statement.electoral_district_item,
      qualifier_p768_name:  statement.electoral_district_name,
      qualifier_p4100:      statement.parliamentary_group_item,
      qualifier_p4100_name: statement.parliamentary_group_name,
      qualifier_p2937:      statement.parliamentary_term_item,
    }
  end

  def wikidata_bot
    ENV.fetch('WIKIDATA_USERNAME')
  end

  def link_to_wiki(title, item = nil)
    if title && item
      content_tag(:span, title) + ' (' + link_to(item, url_to_wiki(item)) + ')'
    elsif title || item
      link_to(title || item, url_to_wiki(title || item))
    end
  end

  def url_to_wiki(title)
    "https://#{ENV['WIKIDATA_SITE']}/wiki/#{title}"
  end
end

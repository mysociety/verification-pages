# frozen_string_literal: true

# Controller to setup wikidata based verification pages
class WikidataPageController < ApplicationController
  def setup
    @page = Page.find_or_initialize_by(title: params[:page_title])
    wiki_page = WikiPageTemplateTag.new(@page.title)
    if @page.update(wiki_page.page_attributes)
      LoadStatements.run(@page.title)
      wikitext = GenerateVerificationPage.run(@page.title)
      wiki_page.update_page(wikitext)
      redirect_to wiki_page.wikidata_url
    else
      render :wikidata_page_setup_error
    end
  end
end

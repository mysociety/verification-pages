import template from './wikilink.html'

export default template({
  props: ['id', 'name'],
  computed: {
    wikidata_site: function () {
      if (typeof window.WIKIDATA_SITE !== 'undefined') {
        return 'https://' + window.WIKIDATA_SITE
      } else {
        return ''
      }
    }
  }
})

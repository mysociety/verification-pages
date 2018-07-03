import template from './wikilink.html'

export default template({
  props: ['id', 'name'],
  computed: {
    wikidata_site: function () {
      if (typeof WIKIDATA_SITE !== 'undefined') {
        return 'https://' + WIKIDATA_SITE
      } else {
        return ''
      }
    }
  }
})

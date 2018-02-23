import wikidataClient from '../wikiapi.js'
import template from './reconcilable.html'

export default template({
  data () { return {} },
  props: ['statement'],
  methods: {
    searchForName: function () {
      const name = this.statement.person_name
      wikidataClient.search(name, 'en', 'en').then(data => {
        console.log(data)
      })
    }
  }
})

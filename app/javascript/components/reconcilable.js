import wikidataClient from '../wikiapi.js'
import template from './reconcilable.html'

export default template({
  data () { return {
    searchResultsLoaded: false,
    searchResults: null,
    chosenPersonItem: null,
  } },
  props: ['statement'],
  methods: {
    searchForName: function () {
      const name = this.statement.person_name
      wikidataClient.search(name, 'en', 'en').then(data => {
        console.log(data);
        this.searchResults = data;
        this.searchResultsLoaded = true;
      })
    },
    reconcileWithItem: function(itemID) {
      alert('FIXME: submit ' + itemID + ' back to verification-pages');
    }
  }
})

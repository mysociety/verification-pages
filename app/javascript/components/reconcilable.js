import wikidataClient from '../wikiapi.js'
import template from './reconcilable.html'

export default template({
  data () { return {
    searchResultsLoading: false,
    searchResultsLoaded: false,
    searchResults: null,
    chosenPersonItem: null,
  } },
  props: ['statement'],
  created: function () {
    this.$parent.$on('statement-changed', () => {
      this.searchResultsLoading = false
      this.searchResultsLoaded = false
    })
  },
  methods: {
    searchForName: function () {
      this.searchResultsLoading = true;
      const name = this.statement.person_name
      wikidataClient.search(name, 'en', 'en').then(data => {
        console.log(data);
        this.searchResults = data;
        this.searchResultsLoaded = true;
        this.searchResultsLoading = false;
      })
    },
    reconcileWithItem: function(itemID) {
      alert('FIXME: submit ' + itemID + ' back to verification-pages');
    }
  }
})

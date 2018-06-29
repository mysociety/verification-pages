import ENV from '../env'
import Axios from 'axios'
import wikidataClient from '../wikiapi'
import template from './reconcilable.html'

export default template({
  data () { return {
    searchResultsLoading: false,
    searchResultsLoaded: false,
    searchResults: null,
    searchResourceType: null
  } },
  props: ['statement', 'country'],
  created: function () {
    this.$parent.$on('statement-changed', () => {
      this.searchResultsLoading = false
      this.searchResultsLoaded = false
    })
  },
  methods: {
    searchForName: function () {
      this.searchResourceType = 'person'
      this.search(this.statement.person_name)
    },
    searchForParty: function () {
      this.searchResourceType = 'party'
      this.search(this.statement.parliamentary_group_name)
    },
    search: function (searchTerm) {
      this.searchResultsLoading = true;
      wikidataClient.search(searchTerm, 'en', 'en').then(data => {
        console.log(data);
        this.searchResults = data;
        this.searchResultsLoaded = true;
        this.searchResultsLoading = false;
      })
    },
    reconcileWithItem: function(itemID) {
      this.$parent.$emit('statement-update', () => {
        return Axios.post(ENV.url + '/reconciliations.json', {
          id: this.statement.transaction_id,
          user: wikidataClient.user,
          item: itemID,
          resource_type: this.searchResourceType
        })
      })
    },
    createPerson: function() {
      wikidataClient.createPerson(
        {
          lang: this.country.label_lang,
          value: this.statement.person_name,
        },
        {
          lang: 'en',
          value: this.country.description_en,
        },
      ).then(createdItemData => {
        this.reconcileWithItem(createdItemData.item);
      })
    },
  }
})

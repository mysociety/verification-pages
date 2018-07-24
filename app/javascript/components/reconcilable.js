import ENV from '../env'
import Axios from 'axios'
import wikidataClient from '../wikiapi'
import template from './reconcilable.html'
import { wikipediaSubdomains } from '../wikipedias'

export default template({
  data () { return {
    searchTerm: null,
    searchResults: null,
    searchResourceType: null,
    languageCode: 'en'
  } },
  props: ['statement', 'page', 'country'],
  created: function () {
    this.languageCode = this.getLanguageCode();
  },
  methods: {
    searchForName: function () {
      this.searchResourceType = 'person'
      if (!this.searchTerm) {
        this.searchTerm = this.statement.person_name
      }
      this.search(this.searchTerm)
    },
    searchForParty: function () {
      this.searchResourceType = 'party'
      if (!this.searchTerm) {
        this.searchTerm = this.statement.parliamentary_group_name
      }
      this.search(this.searchTerm)
    },
    searchForDistrict: function () {
      this.searchResourceType = 'district'
      if (!this.searchTerm) {
        this.searchTerm = this.statement.electoral_district_name
      }
      this.search(this.searchTerm)
    },
    search: function (searchTerm) {
      this.$parent.$emit('loading', 'Loading search results')
      wikidataClient.search(searchTerm, this.getLanguageCode(), 'en').then(data => {
        console.log(data);
        this.searchResults = data;
        this.$parent.$emit('loaded')
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
      this.searchResults = null
      this.searchResourceType = null
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
    changeLanguage: function () {
      localStorage.setItem(wikidataClient.page + '.language', this.languageCode);
      this.updateSearchResults()
    },
    updateSearchResults: function() {
      this.search(this.searchTerm);
    },
    getLanguageCode: function () {
      return localStorage.getItem(wikidataClient.page + '.language') || this.languageCode;
    }
  }
})

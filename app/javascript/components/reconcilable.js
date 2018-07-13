import ENV from '../env'
import Axios from 'axios'
import wikidataClient from '../wikiapi'
import template from './reconcilable.html'

export default template({
  data () { return {
    searchResults: null,
    searchResourceType: null,
    languageCode: 'en',
    languageChooserActive: false
  } },
  props: ['statement', 'page', 'country'],
  created: function () {
    this.languageCode = this.getLanguageCode();
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
    searchForDistrict: function () {
      this.searchResourceType = 'district'
      this.search(this.statement.electoral_district_name)
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
    toggleLanguageChooser: function () {
      this.languageChooserActive = !this.languageChooserActive;
    },
    changeLanguage: function () {
      this.languageChooserActive = false;
      localStorage.setItem(wikidataClient.page + '.language', this.languageCode);

      if (this.searchResourceType == 'person') {
        this.search(this.statement.person_name);
      } else if (this.searchResourceType == 'party') {
        this.search(this.statement.parliamentary_group_name)
      }
    },
    getLanguageCode: function () {
      return localStorage.getItem(wikidataClient.page + '.language') || this.languageCode;
    }
  }
})

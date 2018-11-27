/* global localStorage */
import ENV from '../env'
import Axios from 'axios'
import wikidataClient from '../wikiapi'
import template from './reconcilable.html'

export default template({
  data () {
    return {
      searchTerm: null,
      searchResults: null,
      searchResourceType: null,
      askAboutBulkUpdate: false,
      bulkUpdateItem: null,
      bulkUpdateType: null,
      bulkUpdateCounts: null,
      languageCode: 'en'
    }
  },
  props: ['statement', 'page', 'country'],
  computed: {
    bulkFieldPrefix: function () {
      return {
        'district': 'electoral_district_',
        'party': 'parliamentary_group_'
      }[this.searchResourceType]
    },
    bulkItemAttr: function () { return this.bulkFieldPrefix && (this.bulkFieldPrefix + 'item') },
    bulkNameAttr: function () { return this.bulkFieldPrefix && (this.bulkFieldPrefix + 'name') },
    bulkName: function () { return this.statement[this.bulkNameAttr] }
  },
  created: function () {
    this.statement.bulk_update = false
    this.languageCode = this.getLanguageCode()

    this.$parent.$on('search-for', (field) => {
      this.searchTerm = null

      if (field === 'person') {
        this.searchForName()
      } else if (field === 'electoral_district') {
        this.searchForDistrict()
      } else if (field === 'parliamentary_group') {
        this.searchForParty()
      } else {
        throw new Error('Unknown field to search-for: ' + field)
      }
    })
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
        console.log(data)
        this.searchResults = data
        this.$parent.$emit('loaded')
      })
    },
    createReconciliation: function (itemID, updateType) {
      this.$parent.$emit('statement-update', () => {
        return Axios.post(ENV.url + '/reconciliations.json', {
          id: this.statement.transaction_id,
          user: wikidataClient.user,
          item: itemID,
          resource_type: this.searchResourceType,
          update_type: updateType
        })
      })
    },
    bulkReconcileWithItem: function (itemID) {
      this.askAboutBulkUpdate = false
      this.bulkUpdateItem = null
      if (this.bulkUpdateType) {
        this.createReconciliation(itemID, this.bulkUpdateType)
      }
      this.searchResults = null
      this.searchResourceType = null
    },
    reconcileWithItem: function (itemID) {
      let self = this
      // See if there are any other statements with the same name for
      // this resource type:
      this.$parent.$parent.$emit(
        'find-matching-statements',
        {
          resourceType: this.searchResourceType,
          statement: this.statement,
          nameAttr: this.bulkNameAttr,
          itemAttr: this.bulkItemAttr,
          newItem: itemID
        },
        function (err, counts) {
          if (err) {
            return
          }
          self.bulkUpdateCounts = counts
          if (self.bulkUpdateCounts.otherMatching > 0) {
            // Ask whether to do a bulk reconciliation:
            self.askAboutBulkUpdate = true
            self.bulkUpdateItem = itemID
            self.searchResults = null
          } else {
            // Or go ahead and reconcile just this item:
            self.createReconciliation(itemID, 'single')
            self.searchResults = null
            self.searchResourceType = null
          }
        }
      )
    },
    createPerson: function () {
      wikidataClient.createPerson(
        {
          lang: this.country.label_lang,
          value: this.searchTerm
        },
        {
          lang: 'en',
          value: this.page.new_item_description_en
        }
      ).then(createdItemData => {
        this.reconcileWithItem(createdItemData.item)
      })
    },
    changeLanguage: function () {
      localStorage.setItem(wikidataClient.page + '.language', this.languageCode)
      this.updateSearchResults()
    },
    updateSearchResults: function () {
      this.search(this.searchTerm)
    },
    getLanguageCode: function () {
      return localStorage.getItem(wikidataClient.page + '.language') || this.languageCode
    }
  }
})

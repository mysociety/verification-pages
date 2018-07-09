import Vue from 'vue'
import ENV from './env'
import Axios from 'axios'
import wikidataClient from './wikiapi'
import template from './app.html?style=./app.css'
import { parseFullName } from 'parse-full-name'

import actionWrapper from './components/action_wrapper'

Vue.component('ActionWrapper', actionWrapper)

export default template({
  data () {
    return {
      loaded: false,
      statements: [],
      displayType: 'all',
      sortBy: 'lastName',
      page: null
    }
  },
  computed: {
    currentStatements: function () {
      return this.sortStatements(this.filterStatements(this.statements))
    }
  },
  created: function () {
    this.loadStatements()
    this.$on('statement-update', (requestFunction, cb) => {
      requestFunction().then(response => {
        if (response.data.statements.length > 1) {
          throw 'Response has too many statements. We don\'t know which one to update'
        }
        var newStatement = response.data.statements[0]
        const index = this.statements.findIndex(s => {
          return s.transaction_id === newStatement.transaction_id
        })
        const previousType = this.statements[index].type
        newStatement.previousType = previousType
        this.statements.splice(index, 1, newStatement)
      }).then(cb)
    })
  },
  methods: {
    loadStatements: function () {
      Axios.get(ENV.url + '/statements.json', {
        params: { title: wikidataClient.page }
      }).then(response => {
        this.statements = response.data.statements
        this.page = response.data.page
        this.country = response.data.country
      }).then(() => {
        this.loaded = true
      })
    },
    countStatementsOfType: function (type) {
      if (type !== 'all') {
        return this.statements.filter(s => s.type === type).length
      } else {
        return this.statements.length
      }
    },
    filterStatements: function (statements) {
      if (this.displayType !== 'all') {
        return statements.filter(s => s.type === this.displayType)
      } else {
        return statements
      }
    },
    sortStatements: function (statements) {
      var prefix

      switch (this.sortBy) {
        case 'parliamentaryGroup': prefix = 'parliamentary_group_name'; break
        case 'district': prefix = 'electoral_district_name'; break
      }

      return statements.sort(function (a, b) {
        const nameA = (a[prefix] || '') + parseFullName(a.person_name).last
        const nameB = (b[prefix] || '') + parseFullName(b.person_name).last
        return nameA.localeCompare(nameB)
      })
    }
  }
})

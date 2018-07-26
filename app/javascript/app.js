import Vue from 'vue'
import ENV from './env'
import Axios from 'axios'
import wikidataClient from './wikiapi'
import template from './app.html?style=./app.css'
import { parseFullName } from 'parse-full-name'

import statementComponent from './components/statement'

Vue.component('Statement', statementComponent)

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
    this.$on('statements-loaded', () => {
      this.$nextTick(function () {
        var hash = window.location.hash;
        if (hash) {
          this.$emit('scroll-to-fragment', hash)
        }
      })
    }),
    this.$on('scroll-to-fragment', (fragment) => {
      let selector = fragment.replace(/:/g, '\\:')
      let statementRow = document.querySelector(selector)
      if (statementRow) {
        statementRow.scrollIntoView()
        statementRow.className += " targetted"
      }
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
        this.$emit('statements-loaded')
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
        const namesA = parseFullName(a.person_name)
        const namesB = parseFullName(b.person_name)
        const stringA = (a[prefix] + ' ' || '') + namesA.last + ' ' + namesA.first + ' ' + a.transaction_id
        const stringB = (b[prefix] + ' ' || '') + namesB.last + ' ' + namesB.first + ' ' + b.transaction_id
        return stringA.localeCompare(stringB)
      })
    }
  }
})

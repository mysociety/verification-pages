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
        var statementRow;
        if (hash) {
          statementRow = document.querySelector(hash.replace(/:/g, '\\:'))
          if (statementRow) {
            statementRow.scrollIntoView()
            statementRow.className += " targetted"
          }
        }
      })
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
      return statements.sort((a, b) => {
        const namesA = parseFullName(a.person_name)
        const namesB = parseFullName(b.person_name)
        const statementA = Object.assign({}, a, { firstName: namesA.first, lastName: namesA.last })
        const statementB = Object.assign({}, b, { firstName: namesB.first, lastName: namesB.last })
        let sortFields
        switch (this.sortBy) {
          case 'lastName':
            sortFields = ['lastName', 'firstName']
            break
          case 'parliamentaryGroup':
            sortFields = ['parliamentary_group_name', 'lastName', 'firstName']
            break
          case 'district':
            sortFields = ['electoral_district_name', 'lastName', 'firstName']
            break
        }
        const stringA = sortFields.map(field => statementA[field]).join(' ')
        const stringB = sortFields.map(field => statementB[field]).join(' ')
        return stringA.localeCompare(stringB)
      })
    }
  }
})

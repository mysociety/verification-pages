import Vue from 'vue'
import ENV from './env'
import Axios from 'axios'
import wikidataClient from './wikiapi'
import template from './app.html?style=./app.css'

import actionWrapper from './components/action_wrapper'

Vue.component('ActionWrapper', actionWrapper)

export default template({
  data () {
    return {
      loaded: false,
      submitting: false,
      statements: [],
      statementIndex: 0,
      displayType: 'all',
      page: null
    }
  },
  watch: {
    statementIndex: function (newVal) {
      if (newVal < 0) {
        this.statementIndex = this.currentStatements.length - 1
      } else {
        this.statementIndex = newVal % this.currentStatements.length
      }
      this.$emit('statement-changed')
    }
  },
  computed: {
    statement: function () {
      const statement = this.currentStatements[this.statementIndex]
      if (statement) return statement
      this.statementIndex = this.currentStatements.length - 1
      return this.currentStatements[this.statementIndex]
    },
    currentStatements: function () {
      if (this.displayType !== 'all') {
        return this.statements.filter(s => s.type === this.displayType)
      } else {
        return this.statements
      }
    },
    displayIndex: {
      get: function () { return this.statementIndex + 1 },
      set: function (val) { this.statementIndex = val - 1 }
    }
  },
  created: function () {
    this.loadStatements()
    this.$on('statement-update', requestFunction => {
      this.submitting = true
      requestFunction().then(response => {
        if (response.data.statements.length > 1) {
          throw 'Response has too many statements. We don\'t know which one to update'
        }
        const newStatement = response.data.statements[0]
        const index = this.statements.findIndex(s => {
          return s.transaction_id === newStatement.transaction_id
        })
        this.statements.splice(index, 1, newStatement)
        this.submitting = false
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
      })
    },
    prevStatement: function () {
      this.statementIndex = this.statementIndex - 1
    },
    nextStatement: function () {
      this.statementIndex = this.statementIndex + 1
    },
    countStatementsOfType: function (type) {
      if (type !== 'all') {
        return this.statements.filter(s => s.type === type).length
      } else {
        return this.statements.length
      }
    }
  }
})

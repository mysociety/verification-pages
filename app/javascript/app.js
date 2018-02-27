import ENV from './env'
import Axios from 'axios'
import wikidataClient from './wikiapi'
import template from './app.html'

import verifiableComponent from './components/verifiable'
import unverifiableComponent from './components/unverifiable'
import reconcilableComponent from './components/reconcilable'
import actionableComponent from './components/actionable'
import manuallyActionableComponent from './components/manually_actionable'
import doneComponent from './components/done'

export default template({
  data () {
    return {
      loaded: false,
      submitting: false,
      statements: [],
      statementIndex: 0,
      displayIndex: 1,
      page: null
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
    currentView () {
      switch (this.statement().type) {
        case 'verifiable': return verifiableComponent
        case 'unverifiable': return unverifiableComponent
        case 'reconcilable': return reconcilableComponent
        case 'actionable': return actionableComponent
        case 'manually_actionable': return manuallyActionableComponent
        case 'done': return doneComponent
      }
    },
    statement: function () {
      return this.statements[this.statementIndex]
    },
    loadStatements: function () {
      Axios.get(ENV.url + '/statements.json', {
        params: { title: wikidataClient.page }
      }).then(response => {
        this.statements = response.data.statements
        this.page = response.data.page
      }).then(() => {
        this.loaded = true
      })
    },
    prevStatement: function () {
      this.$emit('statement-changed')
      this.statementIndex = Math.max(this.statementIndex - 1, 0)
      this.displayIndex = this.statementIndex + 1
    },
    nextStatement: function () {
      this.$emit('statement-changed')
      this.statementIndex = (this.statementIndex + 1) % this.statements.length
      this.displayIndex = this.statementIndex + 1
    },
    goToStatement: function () {
      this.$emit('statement-changed')
      var newIndex = parseInt(this.displayIndex) - 1
      newIndex = Math.max(Math.min(newIndex, this.statements.length - 1), 0)
      if (!isNaN(newIndex)) {
        this.statementIndex = newIndex
        this.displayIndex = this.statementIndex + 1
      }
    }
  }
})

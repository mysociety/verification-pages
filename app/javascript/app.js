import Axios from 'axios'
import wikidataClient from './wikiapi.js'
import template from './app.html'

import verifiableComponent from './components/verifiable.js'
import unverifiableComponent from './components/unverifiable.js'
import reconcilableComponent from './components/reconcilable.js'
import actionableComponent from './components/actionable.js'
import manuallyActionableComponent from './components/manually_actionable.js'
import doneComponent from './components/done.js'

export default template({
  data () {
    return {
      loaded: false,
      submitting: false,
      statements: [],
      statementIndex: 0,
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
      const title = encodeURIComponent(wikidataClient.page)
      Axios.get('/statements/' + title + '.json').then(response => {
        this.statements = response.data.statements
        this.page = response.data.page
      }).then(() => {
        this.loaded = true
      })
    },
    prevStatement: function () {
      this.$emit('statement-changed')
      this.statementIndex = Math.max(this.statementIndex - 1, 0);
    },
    nextStatement: function () {
      this.$emit('statement-changed')
      this.statementIndex = (this.statementIndex + 1) % this.statements.length;
    }
  }
})

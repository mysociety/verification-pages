import Axios from 'axios'
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
      statementIndex: 0
    }
  },
  created: function () {
    this.loadStatements()
    this.$on('statement-update', function (statement) {
      const index = this.statements.findIndex(s => {
        return s.transaction_id === statement.transaction_id
      })
      this.statements.splice(index, 1, statement)
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
      Axios.get('/statements/1.json').then(response => {
        this.statements = response.data.statements
      }).then(() => {
        this.loaded = true
      })
    },
    skipStatement: function () {
      this.statementIndex = (this.statementIndex + 1) % this.statements.length;
    }
  }
})

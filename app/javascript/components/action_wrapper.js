import template from './action_wrapper.html'

import loadingComponent from './loading'
import verifiableComponent from './verifiable'
import unverifiableComponent from './unverifiable'
import reconcilableComponent from './reconcilable'
import actionableComponent from './actionable'
import manuallyActionableComponent from './manually_actionable'
import doneComponent from './done'
import revertedComponent from './reverted'

export default template({
  data () {
    return {
      submitting: false,
      error: false,
      loadingText: null
    }
  },
  props: ['statement', 'page', 'country'],
  computed: {
    currentView: function () {
      if (this.submitting) { return loadingComponent }
      switch (this.statement.type) {
        case 'verifiable': return verifiableComponent
        case 'unverifiable': return unverifiableComponent
        case 'reconcilable': return reconcilableComponent
        case 'actionable': return actionableComponent
        case 'manually_actionable': return manuallyActionableComponent
        case 'done': return doneComponent
        case 'reverted': return revertedComponent
      }
    },
    stylingClass: function () {
      if (this.error) { return 'error' }
      return this.statement.type
    }
  },
  created: function () {
    this.$on('loading', text => {
      this.loadingText = text
      this.submitting = true
      this.error = false
    })

    this.$on('loaded', () => {
      this.submitting = false
      this.error = false
    })

    this.$on('error', () => {
      this.submitting = false
      this.error = true
    })

    this.$on('statement-update', requestFunction => {
      this.submitting = true
      this.$parent.$emit('statement-update', requestFunction, () => {
        this.submitting = false
      })
    })
  }
})

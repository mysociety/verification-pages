import Axios from 'axios'
import wikidataClient from '../wikiapi.js'
import template from './verifiable.html'

export default template({
  data () { return {
    submitting: false
  } },
  props: ['statement'],
  methods: {
    verifyStatement: function () {
      this.submitting = true
      const data = {
        id: this.statement.transaction_id,
        user: wikidataClient.user,
        status: true
      }
      Axios.post('/verifications.json', data).then(response => {
        if (response.data.statements.length > 1) {
          throw 'Response has too many statements. We don\'t know which one to update'
        }
        const newStatement = response.data.statements[0]
        this.$parent.$emit('statement-update', newStatement)
        this.submitting = false
      })
    }
  }
})

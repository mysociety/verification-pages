import ENV from '../env'
import Axios from 'axios'
import wikidataClient from '../wikiapi.js'
import template from './verifiable.html'

export default template({
  data () { return {} },
  props: ['statement', 'page'],
  methods: {
    verifyStatement: function () {
      this.$parent.$emit('statement-update', () => {
        return Axios.post(ENV.url + '/verifications.json', {
          id: this.statement.transaction_id,
          user: wikidataClient.user,
          status: true
        })
      })
    }
  }
})

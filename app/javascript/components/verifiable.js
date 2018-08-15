import ENV from '../env'
import Axios from 'axios'
import wikidataClient from '../wikiapi'
import template from './verifiable.html'

export default template({
  data () {
    return {
      referenceURL: ''
    }
  },
  props: ['statement', 'page', 'country'],
  created: function () {
    this.statement.bulk_update = false
  },
  methods: {
    submitStatement: function (status) {
      this.$parent.$emit('statement-update', () => {
        return Axios.post(ENV.url + '/verifications.json', {
          id: this.statement.transaction_id,
          user: wikidataClient.user,
          status
        })
      })
    }
  }
})

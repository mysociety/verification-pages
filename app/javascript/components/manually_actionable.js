import ENV from '../env'
import Axios from 'axios'
import template from './manually_actionable.html'

export default template({
  data () { return {} },
  props: ['statement', 'page', 'country'],
  created: function () {
    this.statement.bulk_update = false
  },
  methods: {
    makeStatementActionable: function () {
      this.$parent.$emit('statement-update', () => {
        return Axios.get(
          ENV.url + '/statements/' + this.statement.transaction_id + '.json',
          { params: { force_type: 'actionable' } }
        )
      })
    }
  }
})

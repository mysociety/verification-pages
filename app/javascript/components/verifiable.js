import ENV from '../env'
import Axios from 'axios'
import Levenshtein from 'js-levenshtein'
import wikidataClient from '../wikiapi'
import template from './verifiable.html'

export default template({
  data () { return {
    changingName: false,
    newName: null
  } },
  props: ['statement', 'page', 'country'],
  methods: {
    submitStatement: function (status) {
      if (this.newName && Levenshtein(this.newName, this.statement.person_name) > 5) {
        alert(
          'The name is too different to the name in the original statement.' +
          '\n\n' +
          'Only minor spelling mistakes should be corrected.'
        )
        return false
      }

      this.$parent.$emit('statement-update', () => {
        return Axios.post(ENV.url + '/verifications.json', {
          id: this.statement.transaction_id,
          user: wikidataClient.user,
          new_name: this.newName,
          status
        })
      })
    },
    changeName: function () {
      this.changingName = true
      this.newName = this.newName || this.statement.person_name
    },
    cancelChangeName: function () {
      this.changingName = false
      this.newName = null
    }
  }
})

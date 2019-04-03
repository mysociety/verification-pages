import ENV from '../env'
import Axios from 'axios'
import wikidataClient from '../wikiapi'
import template from './verifiable.html'

export default template({
  data () {
    return {
      editing: false,
      askAboutOtherStatements: false,
      userReferenceURL: '',
      overrideReferenceURL: '',
      referenceURLScope: 'this-statement'
    }
  },
  props: ['statement', 'page'],
  created: function () {
    this.statement.bulk_update = false
  },
  methods: {
    submitStatement: function (status) {
      this.$parent.$emit('statement-update', () => {
        return Axios.post(ENV.url + '/verifications.json', {
          id: this.statement.transaction_id,
          user: wikidataClient.user,
          status,
          reference_url: this.referenceURL
        }).catch(error => {
          console.log(error)
          this.$parent.$emit('error')
        })
      })
    },
    onChangeReferenceURL: function () {
      if (this.referenceURLScope === 'all-statements') {
        this.$emit('reference-url-change', this.userReferenceURL)
      } else if (this.referenceURLScope === 'this-statement') {
        this.overrideReferenceURL = this.userReferenceURL
      }
      this.editing = false
      this.askAboutOtherStatements = false
    }
  },
  computed: {
    referenceURL: function () {
      return this.overrideReferenceURL || this.page.reference_url
    }
  }
})

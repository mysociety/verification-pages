import template from './verifiable.html'

export default template({
  data () { return {} },
  props: ['statement'],
  methods: {
    verifyStatement: function () {
      this.submitting = true
      const data = {
        id: statement.transaction_id,
        user: 'ExampleUser',
        status: true
      }
      const currentIndex = this.statementIndex
      Axios.post('/verifications.json', data).then(response => {
        if (response.data.statements.length > 1) {
          throw 'Response has too many statements. We don\'t know which one to update'
        }

        const newStatement = response.data.statements[0]
        this.statements[currentIndex] = newStatement
        this.submitting = false
      })
    }
  }
})

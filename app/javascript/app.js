import Axios from 'axios'
import template from './app.html'

export default template({
  data () {
    return {
      loaded: false,
      statements: [],
      statementIndex: 0
    }
  },
  created: function () {
    this.loadStatements()
  },
  methods: {
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
      this.statementIndex++
    }
  }
})

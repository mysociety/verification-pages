import template from './removed.html'

export default template({
  data () { return {} },
  props: ['statement', 'page', 'country'],
  created: function () {
    this.statement.bulk_update = false
  }
})

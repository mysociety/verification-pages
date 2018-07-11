import template from './loading.html'

export default template({
  data () { return {
    message: null
  } },
  props: ['statement', 'page', 'country'],
  created: function () {
    this.$parent.$on('log', data => {
      this.message = data
    })
  }
})

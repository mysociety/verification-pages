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
  },
  computed: {
    text: function () {
      return this.$parent.loadingText || 'Loading'
    }
  }
})

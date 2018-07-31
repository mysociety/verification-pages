import template from './sort_control.html'

export default template({
  data () {
    return {
      sortBy: this.selectedOption
    }
  },
  props: ['options', 'selectedOption']
})

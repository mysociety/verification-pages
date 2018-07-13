import template from './progress.html'

export default template({
  data () { return {} },
  props: [
    'counts'
  ],
  methods: {
    percentageForType: function (type) {
      return (this.counts[type] / this.counts['all']) * 100;
    },
    styleForType: function (type) {
      return 'width: ' + this.percentageForType(type) + '%';
    }
  }
})

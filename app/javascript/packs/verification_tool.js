import Vue from 'vue/dist/vue.esm'
import Axios from 'axios'

document.addEventListener('DOMContentLoaded', () => {
  const app = new Vue({
    el: '#verification-tool',
    data: {
      status: 'Loading...',
      statements: []
    },
    created: function () {
      this.loadStatements()
    },
    methods: {
      loadStatements: function () {
        Axios.get('/statements/2.json').then(response => {
          app.statements = response.data
        }).then(() => {
          app.status = 'Loaded'
        })
      }
    }
  })
})

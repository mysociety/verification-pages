import Vue from 'vue/dist/vue.esm'
import Axios from 'axios'

document.addEventListener('DOMContentLoaded', () => {
  const app = new Vue({
    el: '#verification-tool',
    data: {
      status: 'Loading...',
      statements: [],
      statementIndex: 0,
    },
    created: function () {
      this.loadStatements()
    },
    methods: {
      statement: function() {
        return app.statements[app.statementIndex];
      },
      loadStatements: function () {
        Axios.get('/statements/1.json').then(response => {
          console.log(response.data);
          app.statements = response.data.statements
        }).then(() => {
          app.status = 'Loaded'
        })
      }
    }
  })
})

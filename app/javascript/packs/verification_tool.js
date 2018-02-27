import Vue from 'vue'
import App from '../app'

window.addEventListener('load', () => {
  const el = document.getElementById('js-verification-tool')
                     .appendChild(document.createElement('verification-tool'))

  const app = new Vue({ el, render: h => h(App) })
})

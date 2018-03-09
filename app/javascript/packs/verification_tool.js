import Vue from 'vue'
import App from '../app'
import wikilink from '../components/wikilink'

Vue.component('wikilink', wikilink)

window.addEventListener('load', () => {
  const el = document.getElementById('js-verification-tool')
                     .appendChild(document.createElement('verification-tool'))

  const app = new Vue({ el, render: h => h(App) })
})

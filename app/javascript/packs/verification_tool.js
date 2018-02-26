import Vue from 'vue'
import App from '../app'

window.addEventListener('load', () => {
  const el = document.createElement('verification-tool')
  const spacer = document.createElement('br')
  const heading = document.querySelector('#mw-content-text h1')

  heading.parentNode.insertBefore(spacer, heading.nextSibling)
  heading.parentNode.insertBefore(el, spacer.nextSibling)

  const app = new Vue({ el, render: h => h(App) })
})

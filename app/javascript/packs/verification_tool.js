import Vue from 'vue'
import App from '../app'

document.addEventListener('DOMContentLoaded', () => {
  const el = document.getElementById('mw-content-text')
                     .appendChild(document.createElement('hello'))
  const app = new Vue({ el, render: h => h(App) })
})

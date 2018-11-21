const { environment } = require('@rails/webpacker')
const vue = require('./loaders/vue')
const vueTemplate = require('./loaders/vue_template')

environment.loaders.delete('css')
environment.loaders.delete('sass')
environment.loaders.append('html', vueTemplate.html)
environment.loaders.append('css', vueTemplate.css)

environment.loaders.append('vue', vue)
module.exports = environment

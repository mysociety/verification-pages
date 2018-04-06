const { environment } = require('@rails/webpacker')
const vueTemplate = require('./loaders/vue_template')

environment.loaders.delete('css')
environment.loaders.delete('sass')
environment.loaders.append('html', vueTemplate.html)
environment.loaders.append('css', vueTemplate.css)

module.exports = environment

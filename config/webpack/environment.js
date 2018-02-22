const { environment } = require('@rails/webpacker')
const vueTemplate = require('./loaders/vue_template')

environment.loaders.append('html', vueTemplate)
module.exports = environment

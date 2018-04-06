module.exports = {
  html: {
    test: /\.html(\.erb)?$/,
    use: 'vue-template-loader'
  },
  css: {
    test: /\.css(\.scss)?$/,
    use: ['style-loader', 'css-loader', 'sass-loader']
  }
}

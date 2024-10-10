const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

// Configuration pour jQuery
environment.plugins.append('Provide', new webpack.ProvidePlugin({
  $: 'jquery',
  jQuery: 'jquery'
}))

// Loader pour les fichiers images, y compris .webp
environment.loaders.append('images', {
  test: /\.(png|jpe?g|gif|webp|svg)$/,
  use: [
    {
      loader: 'file-loader',
      options: {
        name: '[name].[hash].[ext]',
        outputPath: 'images/'
      }
    }
  ]
})

// Loader pour les fichiers CSS et SCSS
environment.loaders.append('styles', {
  test: /\.(css|scss|sass)$/,
  use: [
    {
      loader: 'mini-css-extract-plugin/dist/loader',
      options: {}
    },
    'css-loader',
    'sass-loader'
  ]
})

// Assure-toi que les loaders sont configurés pour Babel
environment.loaders.append('babel', {
  test: /\.(js|jsx|mjs)$/,
  exclude: /node_modules/,
  use: {
    loader: 'babel-loader',
    options: {
      presets: ['@babel/preset-env']
    }
  }
})

module.exports = environment

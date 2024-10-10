const { environment } = require('@rails/webpacker');
const webpack = require('webpack');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

// Configuration pour jQuery
environment.plugins.append('Provide', new webpack.ProvidePlugin({
  $: 'jquery',
  jQuery: 'jquery'
}));

// Configuration du loader PostCSS
const postcssLoader = environment.loaders.get('css').use.find(el => el.loader === 'postcss-loader');

if (postcssLoader) {
  postcssLoader.options = {
    postcssOptions: {
      plugins: [
        require('autoprefixer'),
      ]
    }
  };
}

// Configuration du loader SASS
const sassLoader = environment.loaders.get('sass').use.find(el => el.loader === 'sass-loader');

if (sassLoader) {
  sassLoader.options = {
    sourceMap: true // Activer la génération de source map si nécessaire
  };
}

// Loader pour les fichiers SCSS
environment.loaders.append('scss', {
  test: /\.scss$/,
  use: [
    MiniCssExtractPlugin.loader, // Utilisation du loader MiniCssExtractPlugin
    'css-loader',
    {
      loader: 'postcss-loader',
      options: {
        postcssOptions: {
          plugins: [require('autoprefixer')]
        }
      }
    },
    'sass-loader'
  ]
});

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
});

// Loader pour les fichiers CSS et SCSS
environment.loaders.append('styles', {
  test: /\.(css|scss|sass)$/,
  use: [
    MiniCssExtractPlugin.loader, // Utilisation correcte du loader
    'css-loader',
    'sass-loader'
  ]
});

// Loader pour Babel
environment.loaders.append('babel', {
  test: /\.(js|jsx|mjs)$/,
  exclude: /node_modules/,
  use: {
    loader: 'babel-loader',
    options: {
      presets: ['@babel/preset-env']
    }
  }
});

// Ajout du plugin MiniCssExtractPlugin
environment.plugins.append(
  'MiniCssExtractPlugin',
  new MiniCssExtractPlugin({
    filename: '[name].[contenthash].css',
    chunkFilename: '[id].[contenthash].css'
  })
);

module.exports = environment;

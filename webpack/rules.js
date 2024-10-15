const { resolve } = require("path");
const { sourcePath, additionalPaths } = require("./config")
// Extracts CSS into .css file
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
// const loader = require("mini-css-extract-plugin/types/loader");

const getCssLoader = () => {
  return {
    loader: require.resolve('css-loader'),
    options: { sourceMap: true, importLoaders: 2 }
  }
}

const getSassLoader = () => {
  return {
    loader: require.resolve('sass-loader'),
    options: {
      sassOptions: {
        includePaths: additionalPaths
      }
    }
  }
}

const getEsbuildLoader = (options) => {
  return {
    loader: require.resolve('esbuild-loader'),
    options
  }
}

const getEsbuildRule = () => {
  return {
    test: /\.(js|jsx|mjs)?(\.(erb|slim))?$/,
    include: [sourcePath, ...additionalPaths].map((path) => resolve(process.cwd(), path)),
    exclude: /node_modules/,
    use: [ getEsbuildLoader({ target: "es2016" }) ]
  }
}

const getEsbuildCssLoader = () => {
  return getEsbuildLoader({ minify: true })
}

module.exports = () => [
  // Raw
  {
    test: [ /\.html$/ ],
    exclude: [ /\.(js|mjs|jsx|ts|tsx)$/ ],
    type: 'asset/source'
  },
  {
        test: /\.(js|jsx|)$/,
        exclude: /node_modules/,
        use: ['babel-loader'],
  },
  // File
  {
    test: [
      /\.bmp$/,   /\.gif$/,
      /\.jpe?g$/, /\.png$/,
      /\.tiff$/,  /\.ico$/,
      /\.avif$/,  /\.webp$/,
      /\.eot$/,   /\.otf$/,
      /\.ttf$/,   /\.woff$/,
      /\.woff2$/, /\.svg$/
    ],
    exclude: [ /\.(js|mjs|jsx|ts|tsx)$/ ],
    loader: 'file-loader',
    generator: { filename: 'static/[hash][ext][query]' },
    type: 'asset/resource',
    },
  // use: 'file-loader?name=./assets/images/[name].[ext]'
  
  // CSS | images user ==> generator: { filename: 'static/[hash][ext][query]' }
  {
    test: /\.(css)$/i,
    use: [
      MiniCssExtractPlugin.loader,
      getCssLoader(),
      getEsbuildCssLoader()
    ]
  },
  // SASS
  {
    test: /\.(scss|sass)(\.(erb|slim))?$/i,
    use: [
      MiniCssExtractPlugin.loader,
      getCssLoader(),
      getSassLoader()
    ]
  },
  {
    test: /\.(js|jsx)$/,
    exclude: /node_modules/,
    use: ['babel-loader'],
  },
  // Esbuild
  getEsbuildRule(),
]


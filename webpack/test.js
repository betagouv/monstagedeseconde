// webpack/development.js

const path = require("path");
const { devServerPort, publicRootPath, publicTestOutputPath } = require("./config");

module.exports = (webpackConfig) => {
  webpackConfig.devtool = "cheap-module-source-map"

  webpackConfig.stats = {
    colors: true,
    entrypoints: false,
    errorDetails: true,
    modules: false,
    moduleTrace: false
  }

  // Add dev server configs
  webpackConfig.devServer = {
    https: false,
    host: 'localhost',
    port: devServerPort,
    hot: false,
    client: {
      overlay: false,
    },
    // Use gzip compression
    compress: true,
    allowedHosts: "all",
    headers: {
      "Access-Control-Allow-Origin": "*"
    },
    static: {
      publicPath: path.resolve(process.cwd(), `${publicRootPath}/${publicTestOutputPath}`),
      watch: {
        ignored: "**/node_modules/**"
      }
    },
    devMiddleware: {
      publicPath: `/${publicTestOutputPath}/`
    },
    // Reload upon new webpack build
    liveReload: true,
    historyApiFallback: {
      disableDotRule: true
    }
  }

  return webpackConfig;
}

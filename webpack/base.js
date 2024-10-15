const { join, resolve } = require("path");
const fs = require('fs');

const { sourcePath, sourceEntryPath, additionalPaths, publicRootPath, publicOutputPath, cachePath } = require("./config")
const getRules = require("./rules");
const getPlugins = require("./plugins");

const getEntryObject = () => {
  const packsPath = resolve(process.cwd(), join(sourcePath, sourceEntryPath));
  const entryPoints = {}

  fs.readdirSync(packsPath).forEach((packNameWithExtension) => {
    const packName = packNameWithExtension.replace(".js", "").replace(".scss", "");

    if (entryPoints[packName]) {
      entryPoints[packName] = [entryPoints[packName], packsPath + "/" + packNameWithExtension];
    } else {
      entryPoints[packName] = packsPath + "/" + packNameWithExtension;
    }
  });

  return entryPoints;
}

const getModulePaths = () => {
  const result = [resolve(process.cwd(), sourcePath)]

  additionalPaths.forEach((additionalPath) => {
    result.push(resolve(process.cwd(), additionalPath))
  })

  result.push('node_modules')

  return result;
}

const sharedWebpackConfig = (mode) => {
  const isProduction = (mode === "production");
  const hash = isProduction ? "-[contenthash]" : "";

  return {
    mode,
    entry: getEntryObject(),
    optimization: {
      runtimeChunk: false,
      moduleIds: 'deterministic',
      emitOnErrors: false
    },
    resolve: {
      extensions: ['.jsx', '.mjs', '.js', '.sass',
      '.scss', '.css', '.module.sass', '.module.scss',
      '.module.css', '.png', '.svg', '.gif',
      '.jpeg', '.jpg', '.erb', '.avif', '.webp'],
      modules: getModulePaths(),
    },
    resolveLoader: {
      modules: [ 'node_modules' ],
    },
    module: {
      strictExportPresence: true,
      rules: getRules()
    },
    output: {
      filename: "[name]-[chunkhash].js",
      path: resolve(process.cwd(), `${publicRootPath}/${publicOutputPath}`),
      publicPath: `/${publicOutputPath}/`
    },
    plugins: getPlugins(isProduction),
    stats: {
      assets: false
    }
  }
}

module.exports = sharedWebpackConfig;
// ,
// cache: {
//   type: 'filesystem',
//   compression: 'gzip',
//   cacheDirectory: resolve(process.cwd(), cachePath),
//   buildDependencies: {
//     // This makes all dependencies of this file - build dependencies
//     config: [__filename],
//     // By default webpack and loaders are build dependencies
//   },
// }
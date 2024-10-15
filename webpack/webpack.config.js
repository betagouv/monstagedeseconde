const baseConfig = require('./base')
const devConfig = require('./development')
const testConfig = require('./test')
const prodConfig = require('./production')

module.exports = (_, argv) => {
  let webpackConfig = baseConfig(argv.mode);

  if (argv.mode === 'development') {
    devConfig(webpackConfig);
  }

  if (argv.mode === 'test') {
    testConfig(webpackConfig);
  }
  if (argv.mode === 'production') {
    prodConfig(webpackConfig);
  }

  return webpackConfig;
}
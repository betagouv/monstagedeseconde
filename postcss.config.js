module.exports = {
  plugins: [
    require('postcss-import')({
      path: ['src/styles'] // Vous pouvez ajuster ce chemin selon votre projet
    }),
    require('postcss-flexbugs-fixes'),
    require('postcss-preset-env')({
      autoprefixer: {
        flexbox: 'no-2009'
      },
      stage: 3
    }),
  ]
}

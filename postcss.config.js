import postcssImport from 'postcss-import';
import postcssFlexbugsFixes from 'postcss-flexbugs-fixes';
import postcssPresetEnv from 'postcss-preset-env';

export default {
  plugins: [
    postcssImport,
    postcssFlexbugsFixes,
    postcssPresetEnv({
      autoprefixer: {
        flexbox: 'no-2009'
      },
      stage: 3
    }),
  ],
};
// module.exports = {
//   plugins: [
//     require('postcss-import'),
//     require('postcss-flexbugs-fixes'),
//     require('postcss-preset-env')({
//       autoprefixer: {
//         flexbox: 'no-2009'
//       },
//       stage: 3
//     })
//   ]
// }
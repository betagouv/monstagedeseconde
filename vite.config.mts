import { defineConfig } from 'vite';
import RubyPlugin from 'vite-plugin-ruby';
import StimulusHMR from 'vite-plugin-stimulus-hmr';
import inject from '@rollup/plugin-inject';
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [
    RubyPlugin(),
    StimulusHMR(),
    inject({
      $: 'jquery', // this caused warnings for all my scss files that had $variable
      jQuery: 'jquery',
    }),
    react({ include: /\.(mdx|js|jsx|ts|tsx)$/ }),
  ],
  esbuild: {
  },
});
// esbuild: {
//   loader: 'jsx',
//   include: [  /\.jsx?$/ , /\.tsx?$/ ],
// },

// jsxInject: `import React from 'react'`,
//   jsxFactory: 'h',
//   jsxFragment: 'Fragment',
// resolve: {
//   alias: {
//       "~": path.resolve("."),
//   },
// },
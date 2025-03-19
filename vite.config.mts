import { defineConfig } from 'vite';
import RubyPlugin from 'vite-plugin-ruby';
import StimulusHMR from 'vite-plugin-stimulus-hmr';
import inject from '@rollup/plugin-inject';
import path from "path";

export default defineConfig({
  plugins: [
    RubyPlugin(),
    StimulusHMR(),
    inject({
      $: 'jquery', // this caused warnings for all my scss files that had $variable
      jQuery: 'jquery',
    }),
  ],
  esbuild: {
  },
  
});
// jsxInject: `import React from 'react'`,
//   jsxFactory: 'h',
//   jsxFragment: 'Fragment',
// resolve: {
//   alias: {
//       "~": path.resolve("."),
//   },
// },
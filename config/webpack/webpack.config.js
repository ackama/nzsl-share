'use strict';

const { dirname } = require('path');
const webpack = require('webpack');
const {
  config: { source_path: sourcePath },
  generateWebpackConfig
} = require('shakapacker');

module.exports = generateWebpackConfig({
  resolve: {
    alias: {
      jquery: 'jquery/src/jquery'
    }
  },
  module: {
    rules: [
      {
        test: /\.(mp4|webm)$/,
        type: 'asset/resource',
        generator: {
          filename: pathData => {
            const folders = dirname(pathData.filename)
              .replace(`${sourcePath}`, '')
              .split('/')
              .filter(Boolean);

            const foldersWithStatic = ['static', ...folders].join('/');

            return `${foldersWithStatic}/[name]-[hash][ext][query]`;
          }
        }
      }
    ]
  },
  plugins: [
    new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery'
    })
  ],
  ignoreWarnings: [
    // for some reason we're getting really generic deprecation warnings with
    // no actual message - suspect it's related to old dependencies
    /Module Warning \(from \.\/node_modules\/sass-loader\/dist\/cjs\.js\):/u,
    // these primarily come from dependencies like Foundation and are very noisy
    // so lets just exclude them completely until Dart Sass 2 is actually near
    /will be removed in Dart Sass 2\.0\.0/u,
    /You probably don't mean to use the color value/u,
    /To opt into the new behavior, wrap the declaration in `& \{\}`/u
  ]
});

'use strict';

const { dirname } = require('path');
const webpack = require('webpack');
const {
  config: { source_path: sourcePath },
  generateWebpackConfig
} = require('shakapacker');

module.exports = generateWebpackConfig({
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
    // these primarily come from dependencies like Foundation and are very noisy
    // so lets just exclude them completely until Dart Sass 2 is actually near
    /will be removed in Dart Sass 2\.0\.0/u,
    /You probably don't mean to use the color value/u
  ]
});

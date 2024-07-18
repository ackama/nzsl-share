'use strict';

const { dirname } = require('path');
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
  }
});

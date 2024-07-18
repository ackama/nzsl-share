const { environment } = require('@rails/webpacker');
const webpack = require('webpack');

// Add an ProvidePlugin
environment.plugins.prepend(
  'Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    jquery: 'jquery'
  })
);

const svgrLoader = {
  test: /\.svg$/,
  issuer: {
    test: /\.jsx?$/
  },
  use: [
    {
      loader: '@svgr/webpack',
      options: {
        svgoConfig: {
          plugins: [{ prefixIds: false }]
        }
      }
    },
    'file-loader'
  ]
};

// Insert json loader at the top of list
environment.loaders.prepend('svgr', svgrLoader);

const config = environment.toWebpackConfig();

config.resolve.alias = {
  jquery: 'jquery/src/jquery'
};

module.exports = environment;

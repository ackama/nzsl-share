const { webpackConfig, merge } = require('shakapacker')
const customConfig = {
  resolve: {
    extensions: ['.css','.mjs','.js','.sass','.scss','.css','.module.sass','.module.scss','.module.css','.png','.svg','.gif','.jpeg','.jpg','.mp4','.webm']
  }
}

module.exports = merge(webpackConfig, customConfig)
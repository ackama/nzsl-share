'use strict';

const defaultConfigFunc = require('shakapacker/package/babel/preset.js');

/** @type {import('@babel/core').ConfigFunction} */
const config = api => {
  const resultConfig = defaultConfigFunc(api);

  resultConfig.plugins.push(['@babel/plugin-transform-react-jsx']);

  return resultConfig;
};

module.exports = config;

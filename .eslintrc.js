module.exports = {
  root: true,
  parserOptions: {
    ecmaVersion: 13,
    sourceType: 'module'
  },
  extends: [
    'eslint:recommended',
    'plugin:react/recommended',
    'plugin:prettier/recommended'
  ],
  env: {
    commonjs: true,
    node: true,
    browser: true,
    es6: true
  },
  globals: {
    $: 'readonly'
  },
  settings: {
    react: {
      version: 'detect'
    }
  },
  rules: {
    'no-underscore-dangle': 'off',
    'eqeqeq': 'error',
    'guard-for-in': 'error',
    'default-case': 'error',
    'no-with': 'error',
    'radix': 'error',
    'dot-notation': 'error',
    'consistent-this': ['error', 'self'],
    'yoda': 'error',
    'no-shadow': 'error',
    'no-shadow-restricted-names': 'error',
    'new-cap': 'error',
    'no-nested-ternary': 'error',
    'no-plusplus': ['error', { allowForLoopAfterthoughts: true }],
    'spaced-comment': ['warn', 'always', { markers: ['='] }],
    'camelcase': 'error',
    'react/react-in-jsx-scope': 'off',
    'react/prop-types': 'off'
  },
  overrides: [
    {
      files: ['chosen-topics.js'],
      rules: {
        camelcase: 'off'
      }
    }
  ]
};

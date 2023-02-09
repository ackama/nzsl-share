module.exports = {
  root: true,
  parserOptions: {
    ecmaVersion: 13,
    sourceType: 'module'
  },
  extends: [
    'eslint:recommended',
    'plugin:react/recommended'
  ],
  env: {
    browser: true,
    es6: true
  },
  globals: {
    "$": "readonly"
  },
  settings: {
    react: {
      version: "detect"
    }
  },
  rules: {
    "no-underscore-dangle": "off",
    "curly": "error",
    "eqeqeq": "error",
    "guard-for-in": "error",
    "default-case": "error",
    "no-with": "error",
    "radix": "error",
    "dot-notation": "error",
    "consistent-this": [ "error", "self" ],
    "block-spacing": [ "error", "always" ],
    "brace-style": [ "error", "1tbs", { allowSingleLine: true} ],
    "array-bracket-spacing": [ "error", "never" ],
    "yoda": "error",
    "no-shadow": "error",
    "no-shadow-restricted-names": "error",
    "no-trailing-spaces": "error",
    "dot-location": [ "error", "property" ],
    "space-infix-ops": "error",
    "keyword-spacing": "error",
    "space-in-parens": "error",
    "new-cap": "error",
    "space-unary-ops": "error",
    "object-curly-spacing": [ "error", "always" ],
    "no-multiple-empty-lines": "error",
    "no-nested-ternary": "error",
    "semi": [ "error", "always" ],
    "semi-spacing": "error",
    "no-plusplus": [ "error", { "allowForLoopAfterthoughts": true } ],
    "padded-blocks": [ "error", "never" ],
    "space-before-function-paren": [ "error", "never" ],
    "comma-spacing": "error",
    "spaced-comment": [ "warn", "always", { markers: [ "=" ] } ],
    "camelcase": "error",
    "quotes": [ "error", "double" ],
    "react/react-in-jsx-scope": "off",
    "react/prop-types": "off"
  },
  overrides: [
    {
      "files": ["chosen-topics.js"],
      "rules": {
        "camelcase": "off"
      }
    }
  ]
};

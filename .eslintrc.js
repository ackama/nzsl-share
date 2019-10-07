module.exports = {
  root: true,
  parserOptions: {
    ecmaVersion: 6,
    sourceType: 'module'
  },
  extends: 'eslint:recommended',
  env: {
    browser: true
  },
  globals: {
    "$": "readonly"
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
    "quotes": [ "error", "double" ]
  }
};

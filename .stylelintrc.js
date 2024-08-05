module.exports = {
  extends: ['stylelint-config-recommended-scss'],
  rules: {
    'no-descending-specificity': null,
    'string-no-newline': true,
    'color-no-invalid-hex': true,
    'comment-whitespace-inside': 'always',
    'declaration-block-no-duplicate-custom-properties': true,
    'declaration-block-no-duplicate-properties': true,
    'no-invalid-double-slash-comments': true,
    'no-duplicate-at-import-rules': true,
    'length-zero-no-unit': true,
    'scss/at-extend-no-missing-placeholder': null,
    'scss/no-global-function-names': null,
    // this does not apply for SCSS
    'no-invalid-position-at-import-rule': null,
    // this is handled by prettier
    'scss/operator-no-newline-after': null
  }
};

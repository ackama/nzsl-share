module.exports = {
  extends: ['stylelint-config-recommended-scss'],
  rules: {
    'no-descending-specificity': null,
    'scss/no-global-function-names': null,
    // this does not apply for SCSS
    'no-invalid-position-at-import-rule': null,
    // this is handled by prettier
    'scss/operator-no-newline-after': null
  }
};

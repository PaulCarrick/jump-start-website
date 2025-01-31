module.exports = {
  env: {
    browser: true, // Adjust based on your environment
    es2021: true,
  },
  extends: [
    'eslint:recommended',
    'plugin:react/recommended', // Enable recommended React rules
  ],
  parserOptions: {
    ecmaFeatures: {
      jsx: true, // Enable JSX parsing
    },
    ecmaVersion: 12,
    sourceType: 'module',
  },
  plugins: ['react'],
  settings: {
    react: {
      version: 'detect', // Automatically detect React version from dependencies
    },
  },
  rules: {
    // Add or customize your rules here
  },
};

module.exports = {
  testEnvironment: 'node',
  roots: ['<rootDir>/__tests__'],
  testMatch: ['**/*.test.js'],
  moduleNameMapper: {
    '^express$': '<rootDir>/__mocks__/express.js',
  },
  collectCoverageFrom: [
    'index.js',
    'economic.js',
    '!node_modules/**',
  ],
  coverageDirectory: 'coverage',
  verbose: true,
};

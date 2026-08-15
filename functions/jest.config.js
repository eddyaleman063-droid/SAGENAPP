module.exports = {
  testEnvironment: 'node',
  roots: ['<rootDir>/__tests__', '<rootDir>/../api/__tests__'],
  testMatch: ['**/*.test.js'],
  moduleDirectories: ['node_modules', '<rootDir>/node_modules'],
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
